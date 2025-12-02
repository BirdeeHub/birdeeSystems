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
        Can be received in `.data` with `local opts = ...`
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
  };
  options.luaInfo = lib.mkOption {
    type = luaType;
    default = { };
  };
  config.package = lib.mkDefault pkgs.xplr;
  config.drv.passAsFile = [ "nixLuaInit" ];
  config.drv.nixLuaInit = let
    generateConfig = dag:
      if builtins.isString dag then dag
      else builtins.concatStringsSep ",\n  " (
        wlib.dag.sortAndUnwrap {
          inherit dag;
          mapIfOk = v: "(function(...)\n${v.data}\n  end)(\n  ${lib.generators.toLua { } v.opts}, ${builtins.toJSON v.name})";
        }
      );
  in
  /* lua */ ''
    version = ${builtins.toJSON config.package.version}
    package.preload["nix-info"] = function(...)
      return ${lib.generators.toLua { } config.luaInfo}
    end
    local hooks = {
      ${generateConfig config.luaInit}
    }
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
  '';
  config.drv.buildPhase = ''
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
    data = [ "--config" "${placeholder "out"}/${config.binName}-rc.lua" ];
    esc-fn = lib.escapeShellArg;
  } ];
}
