{config, pkgs, self, inputs, ... }: let
in{
  programs.bash = {
    initExtra = ''
      eval "$(oh-my-posh init bash --config ${self}/shell/atomic-emodipt.omp.json)"
    '';
  };
}
