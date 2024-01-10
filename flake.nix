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
    birdeeVim.url = "git+file:./flakes/birdeevim";
  };

  outputs = { self, nixpkgs, home-manager, birdeeVim, ... }@inputs: let
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
    home-modules = import ./modules { homeModule = true; };
    system-modules = import ./modules { homeModule = false; };
  in {
    homeConfigurations = {
      "birdee" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./homes/birdee.nix

          home-modules.shell.bash
          home-modules.shell.zsh
          home-modules.shell.fish
          home-modules.term.alacritty
          home-modules.firefox

          birdeeVim.homeModule.${system}
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = let 
          username = "birdee";
        in {
          inherit username self inputs users stateVersion;
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
          ./systems/asus-configuration.nix

          system-modules.shell.bash
          system-modules.shell.zsh
          system-modules.shell.fish
          system-modules.term.alacritty
          system-modules.i3
          system-modules.hardwares.aSUSrog
          system-modules.hardwares.nvidiaIntelgrated

          birdeeVim.nixosModules.${system}.default
        ];
      };
    };
  };
}
