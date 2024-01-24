pkgs:
rec {
  users = {
    birdee = {
      name = "birdee";
      shell = pkgs.fish;
      isNormalUser = true;
      description = "";
      extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" ];
      # this is packages for nixOS user config.
      # packages = []; # empty because that is managed by home-manager
    };
  };
  git = {
    birdee = {
      userName = "BirdeeHub";
    };
  };
  homeManager = {
    birdee = mkHMdir "birdee";
  };

  mkHMdir = username: let
    username = "birdee";
    homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home";
    homeDirectory = "/${homeDirPrefix}/${username}";
  in {
    inherit username homeDirectory;
  };
}

