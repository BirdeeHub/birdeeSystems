{config, pkgs, lib, wlib, ...}: {
  imports = [ wlib.wrapperModules.quickshell ];
  options.settings = lib.mkOption {
    type = lib.types.addCheck wlib.types.attrsRecursive (x: builtins.all (n: builtins.match "^[a-zA-Z_][a-zA-Z0-9_]*$" n != null) (builtins.attrNames x)) // {
      description = "qml property with json content";
    };
    default = {};
  };
  config.constructFiles.nixInfoQmlDir = {
    relPath = dirOf config.constructFiles.nixInfo.relPath + "/qmldir";
    content = ''
      module NixInfo
      singleton NixInfo 1.0 NixInfo.qml
    '';
  };
  config.prefixVar = [
    [ "QML2_IMPORT_PATH" ":" "${dirOf (dirOf config.constructFiles.nixInfo.path)}" ]
  ];
  config.constructFiles.nixInfo = {
    relPath = "qml-path-dirs/NixInfo/NixInfo.qml";
    content = ''
      pragma Singleton
      import QtQml
      QtObject {
        ${lib.pipe config.settings [
          (lib.mapAttrsToList (n: v:
            "readonly property var ${n}: (${builtins.toJSON v})"
          ))
          (builtins.concatStringsSep "\n  ")
        ]}
      }
    '';
  };
  # NOTE: this doesnt work.
  config.constructFiles.reload = {
    relPath = "bin/quickshell-config-reload";
    content = ''
      #!${pkgs.bash}${pkgs.bash.shellPath}
      ${config.wrapperPaths.placeholder} ipc call top quit
      ${config.wrapperPaths.placeholder}
    '';
    builder = ''
      cp "$1" "$2"
      chmod +x "$2"
    '';
  };
}
