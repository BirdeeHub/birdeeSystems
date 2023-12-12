{config, pkgs, inputs, self, ... }: {
  programs.fish = {
      promptInit = ''
        oh-my-posh init fish --config ${self}/shell/atomic-emodipt.omp.json | source
      '';
  };
}
