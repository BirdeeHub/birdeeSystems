{config, pkgs, inputs, self, lib, ... }: {
  options = {
    birdeeMods.bash.enable = lib.mkEnableOption "birdeeBash";
    birdeeMods.bash.enableTMUX = lib.mkOption {
      description = "bash starts in TMUX";
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf config.birdeeMods.bash.enable (let
    cfg = config.birdeeMods.bash;
  in {
    programs.bash = {
      promptInit = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
      '' + (if cfg.enableTMUX then ''
      '' else "");
    };
  });
}
