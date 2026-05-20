{ inputs, util, ... }:
{
  flake.wrappers.fish = { config, lib, wlib, pkgs, ... }: {
    imports = [ wlib.wrapperModules.fish ];
    configFile.content = ''
      fish_vi_key_bindings
      source ${pkgs.runCommand "fzfinit" { } "${pkgs.fzf}/bin/fzf --fish > $out"}
      source ${inputs.self.wrappers.starship.wrap { inherit pkgs; shell = "fish"; }}/bin/starship
    '';
  };
}
