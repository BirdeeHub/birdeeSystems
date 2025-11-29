{ inputs, birdeeutils, ... }: pkgs:
rec {
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
  git = HM: {
    birdee = {
      enable = true;
      ${if HM then "settings" else "config"} = {
        init.defaultBranch = "master";
        core = {
          autoSetupRemote = true;
          fsmonitor = true;
          # pager = "${pkgs.delta}";
        };
        user.name = "Birdee";
        user.email = "<85372418+BirdeeHub@users.noreply.github.com>";
      };
    };
  };
  homeManager = {
    birdee = mkHMdir "birdee";
  };

  mkHMdir = username: let
    homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home";
    homeDirectory = "/${homeDirPrefix}/${username}";
  in {
    inherit username homeDirectory;
  };
}

