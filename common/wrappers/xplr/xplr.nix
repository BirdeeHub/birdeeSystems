{ config, pkgs, lib, wlib, ... }:
let
  luaType = (pkgs.formats.lua { }).type;
  withPackagesType = let
    inherit (lib.types) package listOf functionTo;
  in (functionTo (listOf package)) // {
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
    extraOptions.opts = lib.mkOption {
      type = luaType;
      default = {};
      description = ''
        Can be received in `.data` with `local opts, name = ...`
      '';
    };
  };
in
{
  imports = [ wlib.modules.default ];
  options.lua = lib.mkOption {
    type = lib.types.package;
    default = pkgs.luajit;
    description = "The lua derivation used to evaluate the `luaEnv` option";
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
  options.luaInit = lib.mkOption {
    type = lib.types.either lib.types.str (configDag lib.types.lines);
    default = { };
    description = ''
      `luaInit` is a flexible configuration option for providing Lua code that will be executed when the Lua environment for `xplr` is initialized.

      It can be either a simple string of Lua code or a structured DAG (directed acyclic graph) of Lua code snippets with dependencies between them.

      The dag type has an extra `opts` field that can be used to pass in options to the lua code.

      It is like the `config.luaInfo` option, but per entry.

      You can then recieve it in `.data` with `local opts, name = ...`

      `{ data, after ? [], before ? [], opts ? {} }`

      **Example usage:**

      ```nix
      luaEnv = lp: [ lp.inspect ];
      luaInit.WillRunEventually = "print('you can also just put a string if you dont want opts or need to run it before or after another')";
      luaInit.TESTFILE_1 = {
        opts = { testval = 1; };
        data = ${"''\n    "+''
          local opts, name = ...
              print(name, require("inspect")(opts))
        ''+"  '';"}
      };
      luaInit.TESTFILE_2 = {
        opts = { testval = 2; };
        after = [ "TESTFILE_1" ];
        data = ${"''\n    "+''
          local opts, name = ...
              print(name, require("inspect")(opts))
              return opts.hooks -- xplr configurations can return hooks
        ''+"  '';"}
      };
      ```

      Here, `TESTFILE_1` runs before `TESTFILE_2`, with their respective options passed in.

      `WillRunEventually` will run at some point, but when is not specified. It could even run between `TESTFILE_1` and `TESTFILE_2`
    '';
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
  config.drv.passAsFile = [ "nixLuaInit" ];
  config.drv.nixLuaInfo = /* lua */ ''
    package.preload["nix-info"] = function()
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
    end
  '';
  config.drv.nixLuaInit = let
    generateConfig = dag: builtins.concatStringsSep ",\n  " (
      wlib.dag.sortAndUnwrap {
        inherit dag;
        mapIfOk = v: "(function(...)\n${v.data}\n  end)(${lib.generators.toLua { } v.opts}, ${builtins.toJSON v.name})";
      }
    );
  in (if builtins.isString config.luaInit then config.luaInit else /*lua*/''
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
      ${generateConfig config.luaInit}
    })
  '');
  /**
    (tset _G :version ${builtins.toJSON config.package.version})
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
       result) {
        ${generateConfig config.luaInit}
       })
  */
  config.drv.buildPhase = let
  in /*bash*/''
    runHook preBuild
    { [ -e "$nixLuaInitPath" ] && cat "$nixLuaInitPath" || echo "$nixLuaInit"; } > ${lib.escapeShellArg "${placeholder "out"}/${config.binName}-rc.lua"}
    runHook postBuild
  '';
  config.suffixVar = let
    withPackages = config.lua.withPackages or pkgs.luajit.withPackages;
    genLuaCPathAbsStr =
      config.lua.pkgs.luaLib.genLuaCPathAbsStr or pkgs.luajit.pkgs.luaLib.genLuaCPathAbsStr;
    genLuaPathAbsStr =
      config.lua.pkgs.luaLib.genLuaPathAbsStr or pkgs.luajit.pkgs.luaLib.genLuaPathAbsStr;
    luaEnv = withPackages config.luaEnv;
  in lib.mkIf ((config.luaEnv config.lua.pkgs) != [ ]) [
    [ "LUA_PATH" ";" (genLuaPathAbsStr luaEnv) ]
    [ "LUA_CPATH" ";" (genLuaCPathAbsStr luaEnv) ]
  ];
  config.addFlag = [ {
    # use addFlag because it allows multiple -c args
    # and while config.flags values can be a list for that purpose,
    # the esc-fn option would be for all of them.
    name = "GENERATED_WRAPPER_LUA";
    data = [ "-c" "${placeholder "out"}/${config.binName}-rc.lua" ];
    esc-fn = lib.escapeShellArg;
  } ];
}
