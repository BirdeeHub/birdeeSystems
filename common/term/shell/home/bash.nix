{config, pkgs, self, inputs, lib, ... }:
{
  options = {
    birdeeMods.bash.enable = lib.mkEnableOption "birdeeBash";
    birdeeMods.bash.TMUXdefault = lib.mkOption {
      description = "bash starts in TMUX";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf config.birdeeMods.bash.enable (let
    cfg = config.birdeeMods.bash;
  in {
    programs.bash = {
      initExtra = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
      '' + (if cfg.TMUXdefault then ''
        [ -z "$TMUX" ] && which tmux &> /dev/null && tmux new-session -A 0
      '' else "");
    };
  });
}
