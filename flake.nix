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
    users = {
      birdee = {
        name = "birdee";
        shell = pkgs.zsh;
        isNormalUser = true;
        description = "";
        extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" ];
        # this is packages for nixOS user config.
        # packages = []; # empty because that is managed by home-manager
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
          ./shell/home/shellModule.nix
          ./term/alacritty/home-alacritty.nix
          ./firefox/homeFox.nix
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
          # nvidia + intel graphics module for a-SUS laptop
          ./hardwares/nvdintGraphics.nix
          ./i3

          ./shell/nixOS/shellModule.nix
          ./term/alacritty/system-alacritty.nix
          birdeeVim.nixosModules.${system}.default
        ];
      };
    };
  };
}
