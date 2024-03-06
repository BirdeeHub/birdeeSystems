inputs: {
  overlayHub = inputs.nixCats.templates.overlayHub;
  overlayFile = inputs.nixCats.templates.overlayFile;
  gradle = {
    path = ./gradle;
    description = "hopefully a working gradle shell?";
  };
  emptyFlake = {
    path = ./emptyFlake;
    description = "an empty flake schema copy paste";
  };
}
