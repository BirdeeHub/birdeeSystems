{config, pkgs, self, inputs, lib, ... }:
{
  options = {
    birdeeMods.bash.enable = lib.mkEnableOption "birdeeBash";
  };
  config = lib.mkIf config.birdeeMods.bash.enable {
    programs.bash = {
      initExtra = ''
        eval "$(oh-my-posh init bash --config ${../atomic-emodipt.omp.json})"
      '';
    };
  };
}
