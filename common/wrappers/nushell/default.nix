{ inputs, birdeeutils, ... }:
{config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.nushell ];
  # # TODO: why this no work
  # "config.nu".content = ''
  #   source ${inputs.self.wrapperModules.starship.wrap { inherit pkgs; shell = "nu"; }}/bin/starship
  # '';
  # # when this does work, and is logically equivalent minus the extra source
  "config.nu".content = ''
    mkdir ($nu.data-dir | path join "vendor/autoload")
    ${inputs.self.wrapperModules.starship.wrap {
      pkgs = pkgs;
      shell = null;
      addFlag = [ "init" "nu" ];
    }}/bin/starship | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
  '';
}
