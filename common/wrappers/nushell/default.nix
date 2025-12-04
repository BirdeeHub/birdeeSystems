{config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.nushell ];
  "config.nu".content = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    $env.STARSHIP_CONFIG = "${pkgs.starship.configuration.env.STARSHIP_CONFIG.data}"
    ${pkgs.starship.wrap { shell = null; addFlag = [ "init" "nu" ]; }}/bin/starship | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';
}
