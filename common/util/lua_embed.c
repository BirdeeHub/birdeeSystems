// Copyright 2025 Birdee
#include <stdio.h>
#include <string.h>
#include <stddef.h>
#include <stdlib.h>
#include <lua.h>
#include <lauxlib.h>
#ifndef __cplusplus
#include <stdbool.h>
#endif
#ifdef _WIN32
#include <windows.h>
#endif

// you can import from arg -DEMBEDDED_LUA_H="/somepath"
// like this:

// #define STR(x) #x
// #define XSTR(x) STR(x)
// #include XSTR(EMBEDDED_LUA_H)

static bool set_env(lua_State *L, const char *key, const char *val) {
#ifdef _WIN32
    return SetEnvironmentVariable(key, val) != 0;
#else
    if (!val) return unsetenv(key) == 0;
    return setenv(key, val, 1) == 0;
#endif
}
static int env__newindex(lua_State *L) {
    const char *key = luaL_checkstring(L, 2);
    const char *val = lua_isnil(L, 3) ? NULL : luaL_checkstring(L, 3);
    if (!set_env(L, key, val))
        return luaL_error(L, "failed to set/unset env var %s", key);
    return 0;
}
static int env__index(lua_State *L) {
    const char *val = getenv(luaL_checkstring(L, 2));
    if (val) lua_pushstring(L, val);
    else lua_pushnil(L);
    return 1;
}
static size_t lembed_arrlen(lua_State *L, int idx) {
#if LUA_VERSION_NUM == 501
    return lua_objlen(L, idx);
#else
    return lua_rawlen(L, idx);
#endif
}
static int embed_run(lua_State *L) {
    // 1: output_file: string
    const char *output_file = luaL_checkstring(L, 1);
    // 2: header_name_or_to_append?: bool|string
    bool to_append = lua_toboolean(L, 2);
    const char *header_name = lua_tostring(L, 2);
    if (header_name) to_append = 0;
    bool table_by_default = lua_toboolean(L, lua_upvalueindex(1));
    size_t num_inputs = lembed_arrlen(L, lua_upvalueindex(2));
    lua_settop(L, 2);
    // @type table<c_func_name, { items: ({ modname: string, chunk: string })[], make_table: bool }>
    lua_newtable(L);
    int todoidx = lua_gettop(L);
    for (size_t i = 1; i <= num_inputs; i++) {
        lua_settop(L, todoidx);
        lua_rawgeti(L, lua_upvalueindex(2), i);
        lua_pushnil(L);
        lua_rawseti(L, lua_upvalueindex(2), i);
        int vidx = lua_gettop(L);
        lua_getfield(L, vidx, "c_fn_name");
        const char *c_func_name = lua_tostring(L, -1);
        lua_getfield(L, vidx, "make_table");
        bool make_table_vote;
        bool make_table_was_null = false;
        if (lua_isnil(L, -1)) {
            make_table_was_null = true;
            make_table_vote = table_by_default;
        } else {
            make_table_vote = lua_toboolean(L, -1);
        }
        lua_pop(L, 1);
        lua_pushnil(L);
        lua_setfield(L, vidx, "make_table");
        lua_getfield(L, todoidx, c_func_name);
        if (!lua_istable(L, -1)) {
            // not present yet → create { items = {}, make_table = make_table_vote }
            lua_pop(L, 1); // remove nil
            lua_newtable(L); // the table for this c_func_name
            lua_newtable(L);
            lua_setfield(L, -2, "items");
            lua_pushboolean(L, make_table_vote);
            lua_setfield(L, -2, "make_table");
            // store it in todoidx[c_func_name]
            lua_pushvalue(L, -1);
            lua_setfield(L, todoidx, c_func_name);
        }
        int func_table_idx = lua_gettop(L);
        lua_pushnil(L);
        lua_setfield(L, vidx, "c_fn_name");

        lua_getfield(L, func_table_idx, "make_table");
        int cur_make_table = lua_toboolean(L, -1);
        lua_pop(L, 1);
        lua_pushboolean(L, make_table_was_null ? cur_make_table : make_table_vote);
        lua_setfield(L, func_table_idx, "make_table");

        // append vidx { modname, chunk } to items
        lua_getfield(L, func_table_idx, "items");
        int items_idx = lua_gettop(L);
        size_t items_len = lembed_arrlen(L, items_idx);
        lua_pushvalue(L, vidx);
        lua_rawseti(L, items_idx, items_len + 1);
    }
    lua_settop(L, todoidx);

    FILE *out = fopen(output_file, to_append ? "ab" : "wb");
    if (!out) return luaL_error(L, "failed to open output");
    if (header_name) fprintf(out, "#ifndef %s\n#define %s\n\n", header_name, header_name);
    fprintf(out, "#include <lua.h>\n#include <lauxlib.h>\n\n");
    lua_pushnil(L);  // next(nil) // get first kv pair on stack
    while (lua_next(L, todoidx) != 0) {
        // now at stack:
        // [-1]: { items: ({ modname: string, chunk: string })[], make_table: bool }
        // [-2]: c_func_name
        const char *c_func_name = lua_tostring(L, -2);
        lua_getfield(L, -1, "make_table");
        const bool make_table = lua_toboolean(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "items");
        int itemsidx = lua_gettop(L);

        fprintf(out, "%sint %s(lua_State *L) {\n", header_name ? "static " : "", c_func_name);
        if (make_table) {
            fprintf(out, "  lua_newtable(L);\n");
            fprintf(out, "  int out_table_idx = lua_gettop(L);\n");
        }
        size_t items_len = lembed_arrlen(L, itemsidx);
        for (size_t i = items_len; i > 0; i--) {
            lua_settop(L, itemsidx);
            lua_rawgeti(L, itemsidx, i);
            lua_getfield(L, -1, "modname");
            const char *modname = lua_tostring(L, -1);
            lua_getfield(L, -2, "chunk");
            size_t chunk_len = 0;
            const char *chunk = lua_tolstring(L, -1, &chunk_len);
            fprintf(out, "  {\n");
            fprintf(out, "    const unsigned char data[] = {\n      ");
            for (size_t i = 0; i < chunk_len; i++) {
                fprintf(out, "0x%02X", (const unsigned char)chunk[i]);
                if (i + 1 < chunk_len) fprintf(out, ",%s", ((i + 1) % 8 != 0) ? " " : "");
                if ((i + 1) % 8 == 0 && i + 1 < chunk_len) fprintf(out, "\n      ");
            }
            fprintf(out, "\n    };\n");
            fprintf(out, "    const size_t len = %zu;\n", chunk_len);
            fprintf(out, "    if (luaL_loadbuffer(L, (const char *)data, len, \"%s\")) {\n", modname);
            fprintf(out, "        const char *err = lua_tostring(L, -1);\n");
            fprintf(out, "        lua_pop(L, 1);\n");
            fprintf(out, "        return luaL_error(L, \"Error loading embedded Lua for %s from function %s: %%s\", err);\n", modname, c_func_name);
            fprintf(out, "    }\n");
            if (make_table) fprintf(out, "    lua_setfield(L, out_table_idx, \"%s\");\n", modname);
            fprintf(out, "  }\n");
        }
        // pop items table and the table for the function
        // leave key for lua_next
        lua_settop(L, itemsidx - 2);
        fprintf(out, "  return %zu;\n", make_table ? 1 : items_len);
        fprintf(out, "}\n");
        lua_pushnil(L);
        lua_setfield(L, todoidx, c_func_name);
    }

    if (header_name) fprintf(out, "\n#endif  // %s\n", header_name);
    fflush(out);
    fclose(out);
    return 0;
}

typedef struct {
    bool first;
    luaL_Buffer *b;
} lembed_writer_data;
static int embed_writer(lua_State *L, const void *p, size_t sz, void *ud) {
    if (!p || !ud) return LUA_ERRERR;
    lembed_writer_data *wd = (lembed_writer_data *)ud;
    if (wd->first) {
        luaL_buffinit(L, wd->b);
        wd->first = false;
    }
    luaL_addlstring(wd->b, (const char *)p, sz);
    return 0;
}
static int embed_add(lua_State *L) {
    static const char *EMBED_USEAGE_MESSAGE = "invalid argument #%d to embed.add!\n"
        "Expected add(modname: string, path: string, c_func_name?: string, make_table?: bool)\n";
    // constructs this, appends it to table in last upvalue
    // { modname = str, c_fn_name = str, make_table = bool?, chunk = str }
    lua_newtable(L);
    lua_insert(L, 1);
    int nargs = lua_gettop(L);
    if (!lua_isstring(L, 2)) return luaL_error(L, EMBED_USEAGE_MESSAGE, 1);
    if (!lua_isstring(L, 3)) return luaL_error(L, EMBED_USEAGE_MESSAGE, 2);
    int type = lua_type(L, 4);
    if (type != LUA_TNIL && type != LUA_TNONE && type != LUA_TSTRING)
        return luaL_error(L, EMBED_USEAGE_MESSAGE, 3);
    else if (nargs < 4) lua_pushnil(L);
    if (nargs > 4) {
        lua_settop(L, 5);
        lua_setfield(L, 1, "make_table");
        lua_settop(L, 4);
    }
    lua_pushvalue(L, 2);
    lua_setfield(L, 1, "modname");
    if (type == LUA_TSTRING) {
        lua_pushvalue(L, 4);
        lua_setfield(L, 1, "c_fn_name");
    } else {
        if (lua_isstring(L, lua_upvalueindex(1))) {
            lua_pushvalue(L, lua_upvalueindex(1));
            lua_setfield(L, 1, "c_fn_name");
        } else {
            // calculate luaopen_mod_path from arg 1 mod.path
            luaL_Buffer b;
            luaL_buffinit(L, &b);
            luaL_addstring(&b, "luaopen_");
            for (const char *p = lua_tostring(L, 2); *p; p++)
                luaL_addchar(&b, (*p == '.') ? '_' : *p);
            luaL_pushresult(&b);
            lua_setfield(L, 1, "c_fn_name");
        }
    }

    if (lua_isfunction(L, lua_upvalueindex(2))) {
        lua_pushvalue(L, lua_upvalueindex(2));
        lua_insert(L, 2);
        if (lua_pcall(L, 3, 1, 0)) {
            const char *err = lua_tostring(L, -1);
            return luaL_error(L, "Error calling loader\n%s", err);
        }
        if (!lua_isfunction(L, -1)) {
            return luaL_error(L, "Loader did not return a function (loaded chunk)");
        }
    } else {
        // load Lua chunk as a function (from arg 2 which is the path)
        if (luaL_loadfile(L, lua_tostring(L, 3)) != 0) {
            const char *err = lua_tostring(L, -1);
            return luaL_error(L, "failed to load Lua file %s at %s\n%s", err);
        }
    }
    luaL_Buffer b;
    lembed_writer_data data = {
        .first = true,
        .b = &b
    };
#if LUA_VERSION_NUM < 503
    if (lua_dump(L, embed_writer, &data)) {
#else
    if (lua_dump(L, embed_writer, &data, true)) {
#endif
        const char *err = lua_tostring(L, -1);
        return luaL_error(L, "Failed to dump Lua bytecode%s at %s\n%s", err);
    }
    luaL_pushresult(&b);
    lua_setfield(L, 1, "chunk");

    // push value for run
    size_t len = lembed_arrlen(L, lua_upvalueindex(3));
    lua_settop(L, 1);
    lua_rawseti(L, lua_upvalueindex(3), len + 1);
    return 0;
}

static int embed_new(lua_State *L) {
    static const char *EMBED_USEAGE_MESSAGE = "invalid argument #%d, expected %s.\nUseage:\n"
        "local embed = require('embed')(c_func_name?: string, loader?: fun(name, path) -> function, table_by_default?: bool)\n"
        "embed.add(modname: string, path: string, c_func_name?: string, make_table?: bool)\n"
        "embed.run(output_file: string, header_name_or_to_append?: bool|string)\n";
    {
        int top = lua_gettop(L);
        lua_newtable(L); // module table
        if (top > 0) lua_replace(L, 1); // <- replace old module value
        else top++;
        if (top > 4) lua_settop(L, 4);
        else for (;top < 4; top++) lua_pushnil(L);
        int type = lua_type(L, 2);
        if (type != LUA_TNIL && type != LUA_TSTRING)
            return luaL_error(L, EMBED_USEAGE_MESSAGE, 1, "string or nil");
        type = lua_type(L, 3);
        if (type != LUA_TNIL && type != LUA_TFUNCTION)
            return luaL_error(L, EMBED_USEAGE_MESSAGE, 2, "function or nil");
    }
    lua_newtable(L); // keeps the values from add for run
    lua_pushvalue(L, -1); // duplicate the table for add
    lua_insert(L, 4);

    // recieves 1: table_by_default, 2: table to read from
    lua_pushcclosure(L, embed_run, 2);
    lua_setfield(L, 1, "run");

    // recieves 1: c_func_name, 2: loader, 3: table to push to
    lua_pushcclosure(L, embed_add, 3);
    lua_setfield(L, 1, "add");

    if (luaL_newmetatable(L, "C_LUA_EMBEDDER_HELPER")) {
        lua_pushcfunction(L, env__index);
        lua_setfield(L, -2, "__index");
        lua_pushcfunction(L, env__newindex);
        lua_setfield(L, -2, "__newindex");
        lua_pushcfunction(L, embed_new);
        lua_setfield(L, -2, "__call");
    }
    lua_setmetatable(L, 1);
    return 1;
}

int luaopen_embed(lua_State *L) {
    lua_newuserdata(L, 0);
    if (luaL_newmetatable(L, "C_LUA_EMBEDDER_HELPER")) {
        lua_pushcfunction(L, env__index);
        lua_setfield(L, -2, "__index");
        lua_pushcfunction(L, env__newindex);
        lua_setfield(L, -2, "__newindex");
        lua_pushcfunction(L, embed_new);
        lua_setfield(L, -2, "__call");
    }
    lua_setmetatable(L, -2);
    return 1;
}
