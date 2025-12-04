{config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.nushell ];
  "config.nu".content = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    $env.STARSHIP_CONFIG = "${pkgs.starship.configuration.env.STARSHIP_CONFIG.data}"
    ${pkgs.starship.wrap { shell = null; }}/bin/starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';
}
