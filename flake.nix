{
  description = "My system config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
  };
  outputs = { self, nixpkgs, flake-utils, home-manager, ... }@inputs: let
    # flake-utils.lib.eachDefaultSystem (system: let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
	inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        nestOS = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
  # );
}
