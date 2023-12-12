{config, pkgs, self, inputs, ... }:
{
  options = {
    birdeeFish.enable = pkgs.lib.mkEnableOption "birdeeFish";
  };
  config = {
    programs.fish = pkgs.lib.mkIf config.birdeeFish.enable {
      enable = true;
      interactiveShellInit = ''
        oh-my-posh init fish --config ${self}/shell/atomic-emodipt.omp.json | source
      '';
    };
  };
}
