{config, pkgs, lib, wlib, ...}: {
  imports = [ wlib.wrapperModules.quickshell wlib.modules.systemd ];
  options.settings = lib.mkOption {
    type = lib.types.addCheck wlib.types.attrsRecursive (x: builtins.all (n: builtins.match "^[a-zA-Z_][a-zA-Z0-9_]*$" n != null) (builtins.attrNames x)) // {
      description = "qml property with json content";
    };
    default = {};
  };
  options.infoModuleName = lib.mkOption {
    type = lib.types.str;
    default = "NixInfo";
  };
  config.constructFiles.nixInfoQmlDir = {
    relPath = dirOf config.constructFiles.nixInfo.relPath + "/qmldir";
    output = config.constructFiles.nixInfo.output;
    content = ''
      module ${config.infoModuleName}
      singleton ${config.infoModuleName} 1.0 ${config.infoModuleName}.qml
    '';
  };
  config.prefixVar = [
    [ "QML2_IMPORT_PATH" ":" "${dirOf (dirOf config.constructFiles.nixInfo.path)}" ]
  ];
  config.constructFiles.nixInfo = {
    relPath = "qml-path-dirs/${config.infoModuleName}/${config.infoModuleName}.qml";
    content = /* qml */ ''
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
}
