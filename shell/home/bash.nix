{config, pkgs, self, inputs, ... }:
{
  options = {
    birdeeBash.enable = pkgs.lib.mkEnableOption "birdeeBash";
  };
  config = {
    programs.bash = pkgs.lib.mkIf config.birdeeBash.enable {
      initExtra = ''
        eval "$(oh-my-posh init bash --config ${self}/shell/atomic-emodipt.omp.json)"
      '';
    };
  };
}
