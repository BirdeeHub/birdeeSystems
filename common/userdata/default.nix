{ inputs, birdeeutils, ... }: pkgs:
{
  birdee = {
    name = "birdee";
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "";
    extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" ];
    # this is packages for nixOS user config.
    # packages = []; # empty because that is managed by home-manager
  };
}

