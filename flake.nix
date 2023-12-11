{
  description = "Home Manager configuration of birdee";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    birdeeVim.url = "git+file:./birdeevim";
  };

  outputs = { self, nixpkgs, home-manager, birdeeVim, ... }@inputs: let
    system = "x86_64-linux";
    stateVersion = "23.05";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    users = {
      birdee = {
        name = "birdee";
        shell = pkgs.zsh;
        isNormalUser = true;
        description = "";
        extraGroups = [ "networkmanager" "wheel" "docker" ];
      };
    };
  in {
    homeConfigurations = {
      "birdee" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          birdeeVim.homeModule.${system}
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
          inherit self inputs stateVersion users;
          hostname = "nestOS";
        };
        modules = [
          ./configuration.nix
           # Include the results of the hardware scan.
          ./hardwares/aSUSrog.nix
          birdeeVim.nixosModules.${system}.default
        ];
      };
    };
  };
}
