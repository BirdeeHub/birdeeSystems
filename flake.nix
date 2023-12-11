{
  description = "Home Manager configuration of birdee";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixCats.url = "/home/birdee/Projects/nixCats-nvim";
    nur.url = "github:nix-community/nur";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    system = "x86_64-linux";
    stateVersion = "23.05";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    homeConfigurations = {
      "birdee" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          # inputs.nixCats.homeModule.${system}
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = let 
          username = "birdee";
          homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "/Users" else "/home";
          homeDirectory = "/${homeDirPrefix}/${username}";
        in {
          inherit homeDirectory username self inputs stateVersion;
        };
      };
    };
    nixosConfigurations = {
      "nestOS" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit self inputs stateVersion;
          username = "birdee";
          hostname = "nestOS";
        };
        modules = [
          ./configuration.nix
          # inputs.nixCats.nixosModules.${system}.default
        ];
      };
    };
  };
}
