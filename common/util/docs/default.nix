{ lib, wlib }: rec {
  collectOptions = import ./collectOptions.nix lib;
  normDocs = import ./normopts.nix { inherit lib collectOptions; };
  renderDocs = import ./rendermd.nix { inherit wlib lib normDocs; };
}
