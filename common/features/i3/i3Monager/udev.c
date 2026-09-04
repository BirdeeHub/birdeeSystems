#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <errno.h>
#include <sys/socket.h>
#include <linux/netlink.h>

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
    for (int i = 1; i < argc; i++) len += strlen(argv[i]);
    char filename[len];

    int fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_KOBJECT_UEVENT);
    if (fd < 0) {
        perror("socket");
        return 1;
    }

    struct sockaddr_nl addr = {
        .nl_family = AF_NETLINK,
        .nl_pid = getpid(),
        .nl_groups = 1,  // receive kernel uevents
    };

    if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("unable to bind file descriptor to NETLINK_KOBJECT_UEVENT");
        return 1;
    }

    // This buffer need only be big enough for the kinds of uevents WE care about.
    // If we receive a larger one, recv will discard the rest.
    // If we were using a different method, maybe we would check to see if it got truncated and handle that.
    // However, we are looking for a specific kind of uevent, and that kind of uevent always fits in this buffer.
    // Keeping it small thus means we at most have to search this many bytes to reject an event.
    char buf[1024];

    for (;;) {
        ssize_t len = recv(fd, buf, sizeof(buf), 0);
        if (len < 0) {
            perror("recv read failure, unable to read from NETLINK_KOBJECT_UEVENT");
            break;
        }

        int action = 0; // ACTION=change
        int subsystem = 0; // SUBSYSTEM=drm
        int devtype = 0; // DEVTYPE=drm_minor
        int hotplug = 0; // HOTPLUG=1
        // A uevent is a sequence of NUL-terminated strings.
        for (char *p = buf; p < buf + len; ) {
            char *end = memchr(p, '\0', buf + len - p);
            if (!end) break;
            if (end == p) break;
            // printf("%s\n", p);
            if (strcmp("SUBSYSTEM=drm", p) == 0) subsystem=1;
            if (strcmp("DEVTYPE=drm_minor", p) == 0) devtype=1;
            if (strcmp("ACTION=change", p) == 0) action=1;
            if (strcmp("HOTPLUG=1", p) == 0) hotplug=1;
            if (action && subsystem && devtype && hotplug) break;
            p = end + 1;
        }
        // printf("--- %zd ---\n", len);
        // fflush(stdout);
        if (action && subsystem && devtype && hotplug) {
            mkdir_p(argv, argc - 1, filename, 1, 0);
            FILE *f = fopen(filename, "w");
            if (!f) {
                perror(filename);
                continue;
            }
            fprintf(f, "display changed\n");
            fflush(f);
            fclose(f);
            printf("wrote to %s\n", filename);
        }
    }
    close(fd);
}
