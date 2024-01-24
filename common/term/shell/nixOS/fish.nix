{config, pkgs, inputs, lib, self, ... }: {
  options = {
    birdeeMods.fish.enable = lib.mkEnableOption "birdeeFish";
  };
  config = lib.mkIf config.birdeeMods.fish.enable (let
    cfg = config.birdeeMods.fish;
  in {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
      '';
      promptInit = ''
        ${pkgs.oh-my-posh}/bin/oh-my-posh init fish --config ${../atomic-emodipt.omp.json} | source
      '';
    };
  });
}
