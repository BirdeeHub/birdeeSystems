{
  description = ''
    IDK how to nix but I'm doing ok.
    It will be cool eventually haha.
  '';

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/nur";
    # birdeeVim.url = "git+file:./flakes/birdeevim";
    flake-utils.url = "github:numtide/flake-utils";
    # nixCats.url = "/home/birdee/Projects/nixCats-nvim";
    nixCats.url = "github:BirdeeHub/nixCats-nvim/frankenstein";
    # have not figured out how to download a debug adapter not on nixpkgs
    # Will be attempting to build this from source in an overlay
    "bash-debug-adapter" = {
      url = "github:rogalmic/vscode-bash-debug";
      flake = false;
    };
    # If you want your plugin to be loaded by the standard overlay,
    # Then you should name it "plugins-something"
    "plugins-nvim-luaref" = {
      url = "github:milisims/nvim-luaref";
      flake = false;
    };
    "plugins-harpoon" = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
    # I use this for autocomplete filler especially for comments. 
    codeium.url = "github:Exafunction/codeium.nvim";
    # I ask this questions I couldnt google the answer to and/or
    # need things I havent heard of. It has better code context than gpt.
    # It also occasionally helps with goto definition.
    sg-nvim.url = "github:sourcegraph/sg.nvim";
  };

  outputs = { self, nixpkgs, home-manager, nixCats, ... }@inputs: let
    system = "x86_64-linux";
    stateVersion = "23.05";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        inputs.nur.overlay
      ];
      config.allowUnfree = true;
    };
    users = import ./userdata pkgs;
    home-modules = import ./modules { homeModule = true; inherit inputs pkgs; };
    system-modules = import ./modules { homeModule = false; inherit inputs pkgs; };
  in {
    packages.${system} = home-modules.birdeeVim.packages;
    homeConfigurations = {
      "birdee" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "birdee";
          inherit self inputs users stateVersion home-modules;
        };
        inherit pkgs;
        modules = [
          ./homes/birdee.nix
        ];
      };
    };
    nixosConfigurations = {
      "nestOS" = nixpkgs.lib.nixosSystem {
        specialArgs = {
          hostname = "nestOS";
          inherit self inputs stateVersion users system-modules;
        };
        inherit system;
        modules = [
          ./systems/aSUS.nix
        ];
      };
    };
  };
}
