{config, pkgs, lib, wlib, ...}: {
  options.settings = lib.mkOption {
    type = wlib.types.attrsRecursive;
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
}
