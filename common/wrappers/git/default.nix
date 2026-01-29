{config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.git ];
  config.settings = {
    init.defaultBranch = "master";
    core = {
      autoSetupRemote = true;
      fsmonitor = true;
      # pager = "${pkgs.delta}";
    };
    user.name = "Birdee";
    user.email = "<85372418+BirdeeHub@users.noreply.github.com>";
  };
}
