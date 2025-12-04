{config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.nushell ];
  "config.nu".content = ''
    source ${pkgs.starship.wrap { shell = "nu"; }}/bin/starship
  '';
}
