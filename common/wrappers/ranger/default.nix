{ config, pkgs, lib, wlib, ... }: {
  imports = [ wlib.modules.default ];
  config.package = pkgs.ranger;
  options.withoutDragon = lib.mkEnableOption "smaller ranger without x-dragon";
  options.terminal = lib.mkOption {
    default = "${config.wrappers.wezterm.wrapper}/bin/wezterm";
    type = wlib.types.stringable;
  };
  options.configFile = lib.mkOption {
    type = wlib.types.file pkgs;
    default.path = pkgs.writeText "nixRangerRC.conf" config.configFile.content;
  };
  config.configFile.content = (if config.withoutDragon then "" else ''
    map <C-Y> shell ${pkgs.dragon-drop} -a -x %p
    map y<C-Y> shell ${pkgs.dragon-drop} --all-compact -x %p
  '') + ''
    set mouse_enabled!
    map ps shell echo "$(${pkgs.xclip}/bin/xclip -o) ." | ${pkgs.findutils}/bin/xargs cp -r
  '';
  config.addFlag = [ "--cmd='source ${config.configFile.path}'" ];
  config.drv.passAsFile = [ "desktop_with_term" ];
  config.filesToPatch = [];
  config.drv.desktop_with_term = /*desktop*/''
    [Desktop Entry]
    Type=Application
    Name=ranger
    Comment=Launches the ranger file manager
    Icon=utilities-terminal
    Terminal=false
    Exec=${config.terminal} -e ${placeholder "out"}/bin/ranger
    Categories=ConsoleOnly;System;FileTools;FileManager
    MimeType=inode/directory;
    Keywords=File;Manager;Browser;Explorer;Launcher;Vi;Vim;Python
  '';
  config.drv.postBuild = ''
    rm -f $out/share/applications/ranger.desktop
    { [ -e "$desktop_with_termPath" ] && cat "$desktop_with_termPath" || echo "$desktop_with_term"; } > $out/share/applications/ranger.desktop
  '';
}
