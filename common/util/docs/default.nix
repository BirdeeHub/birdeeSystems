{ lib, wlib }: rec {
  collectOptions = import ./collectOptions.nix lib;
  normDocs = import ./normopts.nix { inherit wlib lib collectOptions; };
}
