{config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.nushell ];
  # # TODO: why this no work
  # "config.nu".content = ''
  #   source ${pkgs.starship.wrap { shell = "nu"; }}/bin/starship
  # '';
  # # when this does work, and is logically equivalent minus the extra source
  "config.nu".content = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    ${pkgs.starship.wrap {
      shell = null;
      addFlag = [ "init" "nu" ];
    }}/bin/starship | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';
}
