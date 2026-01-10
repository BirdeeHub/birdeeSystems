final: prev:
prev.lib.optionalAttrs (!(prev ? nerd-fonts)) {
  nerd-fonts = {
    go-mono = prev.nerdfonts.override { fonts = [ "Go-Mono" ]; };
    fira-mono = prev.nerdfonts.override { fonts = [ "FiraMono" ]; };
  };
}
