{config, pkgs, self, lib, inputs, ... }:
{
  options = {
    birdeeMods.fish.enable = lib.mkEnableOption "birdeeFish";
  };
  config = lib.mkIf config.birdeeMods.fish.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        oh-my-posh init fish --config ${self}/shell/atomic-emodipt.omp.json | source
      '';
    };
  };
}
