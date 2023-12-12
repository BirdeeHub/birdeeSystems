{config, pkgs, inputs, self, ... }: {
  programs.bash = {
      promptInit = ''
        eval "$(oh-my-posh init bash --config ${self}/shell/atomic-emodipt.omp.json)"
      '';
  };
}
