{config, pkgs, self, inputs, ... }: let
in{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      oh-my-posh init fish --config ${self}/shell/atomic-emodipt.omp.json | source
    '';
  };
}
