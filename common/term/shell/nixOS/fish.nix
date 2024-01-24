{config, pkgs, inputs, lib, self, ... }: {
  options = {
    birdeeMods.fish.enable = lib.mkEnableOption "birdeeFish";
    birdeeMods.fish.enableTMUX = lib.mkEnableOption "fish starts in TMUX";
  };
  config = lib.mkIf config.birdeeMods.fish.enable (let
    cfg = config.birdeeMods.fish;
  in {
    programs.fish = {
      enable = true;
      promptInit = ''
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ${../atomic-emodipt.omp.json} | source
      '' + (if cfg.enableTMUX then ''
        [ -z "$TMUX" ] && which tmux &> /dev/null && tmux has-session && exec tmux attach
        [ -z "$TMUX" ] && which tmux &> /dev/null && tmux has-session || exec tmux
      '' else "");
    };
  });
}
