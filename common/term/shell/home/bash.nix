{config, pkgs, self, inputs, lib, ... }:
{
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
      initExtra = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
      '' + (if cfg.enableTMUX then ''
        [ -z "$TMUX" ] && which tmux &> /dev/null && if [ $(tmux has-sessions &> /dev/null) ]; then
          exec tmux attach
        else
          exec tmux
        fi
      '' else "");
    };
  });
}
