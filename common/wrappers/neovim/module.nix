{ inputs, ... }:
{
  flake.wrappers.neovim = inputs.birdeevim.wrapperModules.neovim;
  flake.modules.homeManager.neovim = {config, lib, ...}: {
    config = lib.mkIf config.wrappers.neovim.enable {
      home.sessionVariables = let
        nvimpath = lib.getExe config.wrappers.neovim.wrapper;
      in {
        EDITOR = nvimpath;
        MANPAGER = "${nvimpath} +Man!";
      };
    };
  };
}
