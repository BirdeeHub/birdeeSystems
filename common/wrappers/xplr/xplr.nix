{
  config,
  pkgs,
  lib,
  wlib,
  ...
}:
let
  luaType = (pkgs.formats.lua { }).type;
  withPackagesType =
    let
      inherit (lib.types) package listOf functionTo;
    in
    (functionTo (listOf package))
    // {
      merge =
        loc: defs: arg:
        (listOf package).merge (loc ++ [ "<function body>" ]) (
          map (
            def:
            def
            // {
              value = def.value arg;
            }
          ) defs
        );
    };
  configDag = wlib.types.dagOf // {
    extraOptions = {
      opts = lib.mkOption {
        type = luaType;
        default = { };
        description = ''
          Can be received in `.data` with `local opts, name = ...`
        '';
      };
      type = lib.mkOption {
        type = lib.types.enum [
          "fnl"
          "lua"
        ];
        default = config.defaultConfigLang;
        description = "The language to be used within this config segment";
      };
    };
  };
  initDal = wlib.dag.sortAndUnwrap { dag = config.luaInit; };
  hasFnl = builtins.any (v: v.type == "fnl") initDal;
  basePluginDir = "${placeholder "out"}/${config.binName}-plugins";
in
{
  imports = [ wlib.modules.default ];
  options.lua = lib.mkOption {
    type = lib.types.package;
    default = pkgs.luajit;
    description = "The lua derivation used to evaluate the `luaEnv` option";
  };
  options.defaultConfigLang = lib.mkOption {
    type = lib.types.enum [
      "fnl"
      "lua"
    ];
    default = "lua";
    description = "The default config language to use for generated config segments. Does not affect the `luaInfo` option.";
  };
  options.luaEnv = lib.mkOption {
    type = withPackagesType;
    default = lp: [ ];
    description = ''
      extra lua packages to add to the lua environment for wezterm

      value is to be a function from `config.lua.pkgs` to list

      `config.lua.withPackages config.luaEnv`

      The result will be added to package.path and package.cpath
    '';
  };
  options.plugins = lib.mkOption {
    type = wlib.types.dagOf wlib.types.stringable;
    default = { };
    description = ''
      Will be symlinked into a directory added to the `LUA_PATH` and `LUA_CPATH`

      The name of the plugin via `require` will be the dag name for the value.

      The name nix-info is not allowed.
    '';
  };
  options.luaInit = lib.mkOption {
    type = lib.types.either lib.types.str (configDag lib.types.lines);
    default = { };
    description = builtins.readFile ./initdesc.md;
  };
  options.infopath = lib.mkOption {
    type = lib.types.str;
    default = "nix-info";
    description = "The default require path for the result of the luaInfo option";
  };
  options.luaInfo = lib.mkOption {
    type = luaType;
    default = { };
    description = ''
      `luaInfo` is a Lua table that can hold arbitrary data you want to expose to your Lua environment.

      This table is automatically converted to Lua code and made available under `require "nix-info"`.
    '';
  };
  config.package = lib.mkDefault pkgs.xplr;
  config.drv.passAsFile = [ "nixLuaInit" "nixLuaInfo" ];
  config.drv.nixLuaInfo = /* lua */ ''
    return setmetatable(${lib.generators.toLua { } config.luaInfo}, {
      __call = function(self, default, ...)
        if select('#', ...) == 0 then return default end
        local tbl = self;
        for _, key in ipairs({...}) do
          if type(tbl) ~= "table" then return default end
          tbl = tbl[key]
        end
        return tbl
      end
    })
  '';
  config.drv.nixLuaInit =
    let
      versionstr =
        if hasFnl then
          "(tset _G :version ${builtins.toJSON config.package.version})"
        else
          "version = ${builtins.toJSON config.package.version}";
      generatedConfig = lib.pipe initDal [
        (map (
          v:
          let
            lua = "(function(...) ${v.data} end)(${lib.generators.toLua { } v.opts}, ${builtins.toJSON v.name})";
            fnl = ''((fn [...] ${v.data}) (lua "" ${builtins.toJSON "${lib.generators.toLua { } v.opts}"}) ${builtins.toJSON v.name})'';
          in
          if hasFnl then if v.type == "fnl" then fnl else ''(lua "" ${builtins.toJSON lua})'' else lua
        ))
        (builtins.concatStringsSep (if hasFnl then "\n" else ",\n"))
      ];

      nixInit = (
        if builtins.isString config.luaInit then
          config.luaInit
        else if hasFnl then
          /* fennel */ ''
            ((fn [hooks]
               (fn add-hooks [res b]
                 (each [k vlist (pairs b)]
                   (local acc (. res k))
                   (if (not= (type acc) :table) (tset res k vlist)
                       (not= (type vlist) :table)
                       (error (.. "expected a list of hooks at " (tostring k)
                                  ", but got a " (type vlist)))
                       (let [n (length acc)]
                         (for [i 1 (length vlist)] (tset acc (+ n i) (. vlist i))))))
                 res)

               (var result {})
               (each [_ h (ipairs hooks)]
                 (when (= (type h) :table) (set result (add-hooks result h))))
               result) [
                ${generatedConfig}
               ])''
        else
          /* lua */ ''
            return (function(hooks)
              local function add_hooks(res, b)
                for k, vlist in pairs(b) do
                  local acc = res[k]
                  if type(acc) ~= "table" then
                    res[k] = vlist
                  elseif type(vlist) ~= "table" then
                    error("expected a list of hooks at ".. tostring(k) ..", but got a " .. type(vlist))
                  else
                    local n = #acc
                    for i = 1, #vlist do
                      acc[n + i] = vlist[i]
                    end
                  end
                end
                return res
              end
              local result = {}
              for _, h in ipairs(hooks) do
                if type(h) == "table" then
                  result = add_hooks(result, h)
                end
              end
              return result
            end)({
              ${generatedConfig}
            })''
      );
    in
    ''
      ${versionstr}
      ${nixInit}
    '';
  config.drv.buildPhase =
    let
      errORname = name: if name == config.infopath
          then "plugin name '${config.infopath}' already taken by luaInfo result. Change the name, or value of `config.infopath`"
        else if name == null
          then "name must be provided for a plugin!"
        else name;
      mkLinkCommand =
        name: plugin:
        "ln -s ${lib.escapeShellArg plugin} ${lib.escapeShellArg "${basePluginDir}/${errORname name}"}";
      linkCommands = wlib.dag.sortAndUnwrap { dag = config.plugins; mapIfOk = v: mkLinkCommand v.name v.data; };
    in
    /* bash */ ''
      runHook preBuild
      mkdir -p ${lib.escapeShellArg "${basePluginDir}"}
      { [ -e "$nixLuaInitPath" ] && cat "$nixLuaInitPath" || echo "$nixLuaInit"; }${
        if hasFnl then " | ${pkgs.luajitPackages.fennel}/bin/fennel --compile - " else " "
      }> ${lib.escapeShellArg "${placeholder "out"}/${config.binName}-rc.lua"}
      { [ -e "$nixLuaInfoPath" ] && cat "$nixLuaInfoPath" || echo "$nixLuaInfo"; } > ${lib.escapeShellArg "${basePluginDir}/${config.infopath}.lua"}
      ${builtins.concatStringsSep "\n" linkCommands}
      runHook postBuild
    '';
  config.prefixVar =
    let
      withPackages = config.lua.withPackages or pkgs.luajit.withPackages;
      genLuaCPathAbsStr =
        config.lua.pkgs.luaLib.genLuaCPathAbsStr or pkgs.luajit.pkgs.luaLib.genLuaCPathAbsStr;
      genLuaPathAbsStr =
        config.lua.pkgs.luaLib.genLuaPathAbsStr or pkgs.luajit.pkgs.luaLib.genLuaPathAbsStr;
      luaEnv = withPackages config.luaEnv;
    in
    lib.mkIf ((config.luaEnv config.lua.pkgs) != [ ]) [
      [
        "LUA_PATH"
        ";"
        ("${basePluginDir}/?.lua;${basePluginDir}/?/init.lua;" + genLuaPathAbsStr luaEnv)
      ]
      [
        "LUA_CPATH"
        ";"
        ("${basePluginDir}/?.so;" + genLuaCPathAbsStr luaEnv)
      ]
    ];
  config.addFlag = [
    {
      # use addFlag because it allows multiple -c args
      # and while config.flags values can be a list for that purpose,
      # the esc-fn option would be for all of them.
      name = "GENERATED_WRAPPER_LUA";
      data = [
        "-c"
        "${placeholder "out"}/${config.binName}-rc.lua"
      ];
      esc-fn = lib.escapeShellArg;
    }
  ];
}
