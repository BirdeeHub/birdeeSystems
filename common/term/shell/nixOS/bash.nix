{config, pkgs, inputs, self, lib, ... }: {
  options = {
    birdeeMods.bash.enable = lib.mkEnableOption "birdeeBash";
  };
  config = lib.mkIf config.birdeeMods.bash.enable (let
    cfg = config.birdeeMods.bash;
  in {
    programs.bash = {
      promptInit = ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
      '';
    };
  });
}
