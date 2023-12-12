{config, pkgs, inputs, self, ... }: {
  options = {
    birdeeFish.enable = pkgs.lib.mkEnableOption "birdeeFish";
  };
  config = {
    programs.fish = pkgs.lib.mkIf config.birdeeFish.enable {
        promptInit = ''
          oh-my-posh init fish --config ${self}/shell/atomic-emodipt.omp.json | source
        '';
    };
  };
}
