{config, pkgs, inputs, lib, self, ... }: {
  options = {
    birdeeMods.fish.enable = lib.mkEnableOption "birdeeFish";
  };
  config = lib.mkIf config.birdeeMods.fish.enable {
    programs.fish = {
      enable = true;
      promptInit = ''
        oh-my-posh init fish --config ${../atomic-emodipt.omp.json} | source
      '';
    };
  };
}
