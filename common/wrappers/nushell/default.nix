{config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.nushell ];
  "config.nu".content = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    ${pkgs.starship.wrap {
      shell = null;
      addFlag = [ "init" "nu" ];
    }}/bin/starship | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';
}
