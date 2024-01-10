{config, pkgs, inputs, self, lib, ... }: {
  options = {
    birdeeMods.bash.enable = lib.mkEnableOption "birdeeBash";
  };
  config = lib.mkIf config.birdeeMods.bash.enable {
    programs.bash = {
      promptInit = ''
        eval "$(oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
      '';
    };
  };
}
