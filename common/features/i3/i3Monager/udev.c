#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <errno.h>
#include <poll.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/stat.h>
#include <libudev.h>

int mkdir_p(const char **path, int last, char *buf, int current, size_t len);
int mkdir_p(const char **path, int last, char *buf, int current, size_t len) {
    buf[len] = '/';
    size_t l = strlen(path[current]);
    strcpy(buf + len + 1, path[current]);
    len += l + 1;
    if (current != last) {
        struct stat st;

        if (stat(buf, &st) == -1) {
            if (errno != ENOENT) {
                perror(buf);
                return 0;
            }

            if (mkdir(buf, 0755) == -1) {
                perror(buf);
                return 0;
            }
        } else if (!S_ISDIR(st.st_mode)) {
            fprintf(stderr, "%s exists but is not a directory\n", buf);
            return 0;
        }
        return mkdir_p(path, last, buf, current + 1, len);
    }
    return 1;
}

int main(int argc, const char **argv)
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <path> <of> <trigger> <file>\n", argv[0]);
        return 1;
    }

    size_t len = 1 + argc;
    for (int i = 1; i < argc; i++)
        len += strlen(argv[i]);
    char filename[len];

    struct udev *udev = udev_new();
    if (!udev) {
        fprintf(stderr, "udev_new() failed\n");
        return 1;
    }

    struct udev_monitor *monitor =
        udev_monitor_new_from_netlink(udev, "kernel");

    if (!monitor) {
        fprintf(stderr, "udev_monitor_new_from_netlink() failed\n");
        udev_unref(udev);
        return 1;
    }

    /*
     * Match:
     *
     *     SUBSYSTEM=="drm"
     *     DEVTYPE=="drm_minor"
     */
    int r = udev_monitor_filter_add_match_subsystem_devtype(
        monitor, "drm", "drm_minor");

    if (r < 0) {
        fprintf(stderr, "filter failed: %d\n", r);
        udev_monitor_unref(monitor);
        udev_unref(udev);
        return 1;
    }

    udev_monitor_set_receive_buffer_size(monitor, 16 * 1024 * 1024);

    /*
     * Start receiving events.
     */
    r = udev_monitor_enable_receiving(monitor);

    if (r < 0) {
        fprintf(stderr, "enable_receiving failed: %d\n", r);
        udev_monitor_unref(monitor);
        udev_unref(udev);
        return 1;
    }

    /*
     * Get the monitor's file descriptor.
     */
    int fd = udev_monitor_get_fd(monitor);

    if (fd < 0) {
        fprintf(stderr, "udev_monitor_get_fd() failed\n");
        udev_monitor_unref(monitor);
        udev_unref(udev);
        return 1;
    }

    struct pollfd pfd = {
        .fd = fd,
        .events = POLLIN,
        .revents = 0,
    };

    for (;;) {

        printf("Waiting for DRM events...\n");
        fflush(stdout);
        /*
         * Block indefinitely.
         *
         * -1 means:
         *   do not wake up until the fd has something to read.
         */
        int ret = poll(&pfd, 1, -1);

        if (ret < 0) {
            /*
             * Signals can interrupt poll().
             * Just go back to waiting.
             */
            if (errno == EINTR)
                continue;

            perror("poll");
            break;
        }

        /*
         * Something other than normal input happened.
         */
        if (pfd.revents & (POLLERR | POLLHUP | POLLNVAL)) {
            fprintf(stderr, "udev monitor fd error: 0x%x\n",
                    pfd.revents);
            break;
        }

        /*
         * The monitor has an event waiting.
         */
        if (!(pfd.revents & POLLIN))
            continue;

        struct udev_device *device =
            udev_monitor_receive_device(monitor);

        if (!device) {
            /*
             * This should be unusual after poll() reported POLLIN,
             * but don't spin if it happens.
             */
            continue;
        }

        const char *action =
            udev_device_get_action(device);

        const char *subsystem =
            udev_device_get_subsystem(device);

        const char *devtype =
            udev_device_get_devtype(device);

        const char *hotplug =
            udev_device_get_property_value(device, "HOTPLUG");

        printf(
            "EVENT: action=%s subsystem=%s devtype=%s HOTPLUG=%s\n",
            action ? action : "(null)",
            subsystem ? subsystem : "(null)",
            devtype ? devtype : "(null)",
            hotplug ? hotplug : "(null)"
        );

        /*
         * Equivalent to:
         *
         *     ACTION=="change"
         *     SUBSYSTEM=="drm"
         *     DEVTYPE=="drm_minor"
         *     ENV{HOTPLUG}=="1"
         */
        if (action &&
            strcmp(action, "change") == 0 &&
            hotplug &&
            strcmp(hotplug, "1") == 0) {
            mkdir_p(argv, argc - 1, filename, 1, 0);
            FILE *f = fopen(filename, "w");
            if (!f) {
                perror(filename);
                continue;
            }
            fprintf(f, "display changed\n");
            fflush(f);
            fclose(f);
        }

        udev_device_unref(device);
    }

    udev_monitor_unref(monitor);
    udev_unref(udev);

    return 0;
}
