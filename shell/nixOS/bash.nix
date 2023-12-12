{config, pkgs, inputs, self, ... }: {
  options = {
    birdeeBash.enable = pkgs.lib.mkEnableOption "birdeeBash";
  };
  config = {
    programs.bash = pkgs.lib.mkIf config.birdeeBash.enable {
      promptInit = ''
        eval "$(oh-my-posh init bash --config ${self}/shell/atomic-emodipt.omp.json)"
      '';
    };
  };
}
