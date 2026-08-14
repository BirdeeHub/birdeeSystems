#include <lua.h>
#include <lauxlib.h>

#include <sys/inotify.h>
#include <unistd.h>

#include <errno.h>
#include <limits.h>
#include <string.h>

#define WATCHER_MT_NAME "inotify.watcher"

struct watcher {
    int fd;
    int wd;
};

static int l_watcher_wait(lua_State *L) {
    struct watcher *w = luaL_checkudata(L, 1, WATCHER_MT_NAME);
    const char *filename = luaL_checkstring(L, 2);

    char buf[sizeof(struct inotify_event) + NAME_MAX + 1];

    for (;;) {
        ssize_t n = read(w->fd, buf, sizeof(buf));

        if (n < 0) {
            if (errno == EINTR) continue;
            return luaL_error(L, "inotify read: %s", strerror(errno));
        }
        size_t offset = 0;
        while (offset < (size_t)n) {
            struct inotify_event *event = (struct inotify_event *)(buf + offset);

            if ((event->mask & IN_CLOSE_WRITE)
                && event->len > 0
                && strcmp(event->name, filename) == 0
            ) {
                return 0;
            }

            offset += sizeof(struct inotify_event) + event->len;
        }
    }
}

static int l_watcher_close(lua_State *L) {
    struct watcher *w = luaL_checkudata(L, 1, WATCHER_MT_NAME);
    if (w->fd != -1) {
        inotify_rm_watch(w->fd, w->wd);
        close(w->fd);
        w->fd = -1;
        w->wd = -1;
    }
    return 0;
}

static int l_watch(lua_State *L) {
    const char *directory = luaL_checkstring(L, 1);

    int fd = inotify_init1(0);
    if (fd == -1) return luaL_error(L, "inotify_init1: %s", strerror(errno));

    int wd = inotify_add_watch(fd, directory, IN_CLOSE_WRITE);
    if (wd == -1) {
        int err = errno;
        close(fd);
        return luaL_error(L, "inotify_add_watch(%s): %s", directory, strerror(err));
    }

    struct watcher *w = (struct watcher *)lua_newuserdata(L, sizeof(struct watcher));
    w->fd = fd;
    w->wd = wd;
    luaL_setmetatable(L, WATCHER_MT_NAME);
    return 1;
}

int luaopen_filewatcher(lua_State *L) {
    // Create watcher metatable.
    luaL_newmetatable(L, WATCHER_MT_NAME);
    lua_pushcfunction(L, l_watcher_close);
    lua_setfield(L, -2, "__gc");
    lua_newtable(L);
    lua_pushcfunction(L, l_watcher_close);
    lua_setfield(L, -2, "close");
    lua_pushcfunction(L, l_watcher_wait);
    lua_setfield(L, -2, "wait");
    lua_setfield(L, -2, "__index");
    lua_pop(L, 1);

    lua_pushcfunction(L, l_watch);
    return 1;
}
