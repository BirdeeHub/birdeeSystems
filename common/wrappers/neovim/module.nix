{ inputs, ... }:
{
  flake.wrappers.neovim = top: {
    imports = [ inputs.birdeevim.wrapperModules.neovim ];
    install.modules.homeManager =
      { config, lib, ... }:
      let
        cfg = top.config.install.getWrapperConfig config;
      in
      {
        home.sessionVariables =
          let
            nvimpath = lib.getExe cfg.wrapper;
          in
          {
            EDITOR = nvimpath;
            MANPAGER = "${nvimpath} +Man!";
          };
      };
  };
}
