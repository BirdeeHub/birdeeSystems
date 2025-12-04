{ pkgs, lib, wlib, config, ... }: {
  config.filesToPatch = lib.mkForce [];
  config.drv.desktop_with_term = lib.mkIf (config.termCmd != null) /* desktop */ ''
    [Desktop Entry]
    Type=Application
    Name=xplr
    Comment=Launches the xplr file manager
    Icon=utilities-terminal
    Terminal=false
    Exec=${config.termCmd} -e ${placeholder "out"}/bin/${config.binName}
    Categories=ConsoleOnly;System;FileTools;FileManager
    MimeType=inode/directory;
    Keywords=File;Manager;Browser;Explorer;Launcher;Vi;Vim;Python
  '';
  config.drv.passAsFile = lib.mkIf (config.termCmd != null) [ "desktop_with_term" ];
  config.drv.postBuild = lib.mkIf (config.termCmd != null) /* bash */''
    rm -f $out/share/applications/xplr.desktop
    { [ -e "$desktop_with_termPath" ] && cat "$desktop_with_termPath" || echo "$desktop_with_term"; } > $out/share/applications/xplr.desktop
  '';
  options.termCmd = lib.mkOption {
    type = lib.types.nullOr wlib.types.stringable;
    default = null;
  };
}
