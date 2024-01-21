# Copyright (c) 2023 BirdeeHub 
# Licensed under the MIT license 
{inputs, ... }@attrs: let
  inherit (inputs.nixCats) utils;
  luaPath = "${./.}";
  # the following extra_pkg_config contains any values
  # which you want to pass to the config set of nixpkgs
  # import nixpkgs { config = extra_pkg_config; inherit system; }
  # will not apply to module imports
  # as that will have your system values
  extra_pkg_config = {
    # allowUnfree = true;
  };
  system_resolved = inputs.flake-utils.lib.eachDefaultSystem (system: let
    # see :help nixCats.flake.outputs.overlays
    # This overlay grabs all the inputs named in the format
    # `plugins-<pluginName>`
    # Once we add this overlay to our nixpkgs, we are able to
    # use `pkgs.neovimPlugins`, which is a set of our plugins.
    dependencyOverlays = [ (utils.mergeOverlayLists inputs.nixCats.dependencyOverlays.${system}
    ((import ./overlays inputs) ++ [
      (utils.standardPluginOverlay inputs)
      # add any flake overlays here.
      inputs.codeium.overlays.${system}.default
    ])) ];
  in { inherit dependencyOverlays; });
  inherit (system_resolved) dependencyOverlays;

  categoryDefinitions = { pkgs, settings, categories, name, ... }@packageDef: {

    propagatedBuildInputs = {
      generalBuildInputs = with pkgs; [
      ];
    };

    lspsAndRuntimeDeps = {
      general = with pkgs; [
        universal-ctags
        ripgrep
        fd
      ];
      bitwarden = with pkgs; [
        bitwarden-cli
      ];
      AI = [
        inputs.codeium.packages.${pkgs.system}.codeium-lsp
        inputs.sg-nvim.packages.${pkgs.system}.default
      ];
      java = with pkgs; [
        jdt-language-server
      ];
      kotlin = with pkgs; [
        kotlin-language-server
      ];
      lua = with pkgs; [
        lua-language-server
      ];
      nix = with pkgs; [
        nix-doc
        nil
        nixd
      ];
      neonixdev = with pkgs; [
        # nix-doc tags will make your tags much better in nix
        # but only if you have nil as well for some reason
        nix-doc
        nil
        lua-language-server
        nixd
      ];
      bash = with pkgs; [
        bashdb # a bash debugger. seemed like an easy first debugger to add, and would be useful
        pkgs.nixCatsBuilds.bash-debug-adapter # I unfortunately need to build it I think... IDK how yet.
      ];
    };

    startupPlugins = {
      neonixdev = [
        pkgs.vimPlugins.neodev-nvim
        pkgs.vimPlugins.neoconf-nvim
        pkgs.neovimPlugins.nvim-luaref
      ];
      AI = [
        pkgs.vimPlugins.codeium-nvim
        inputs.sg-nvim.packages.${pkgs.system}.sg-nvim
      ];
      debug = with pkgs.vimPlugins; [
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
      ];
      general = with pkgs.vimPlugins; {
        theme = builtins.getAttr categories.colorscheme { 
          "onedark" = onedark-nvim;
          "catppuccin" = catppuccin-nvim;
          "catppuccin-mocha" = catppuccin-nvim;
          "tokyonight" = tokyonight-nvim;
          "tokyonight-day" = tokyonight-nvim;
        };
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
        ];
        StdPlugOver = with pkgs.neovimPlugins; [
          harpoon
          hlargs
        ];
        cmp = [
          # cmp stuff
          nvim-cmp
          luasnip
          cmp_luasnip
          cmp-buffer
          cmp-path
          cmp-nvim-lua
          cmp-nvim-lsp
          friendly-snippets
          cmp-cmdline
          cmp-nvim-lsp-signature-help
          cmp-cmdline-history
          lspkind-nvim
        ];
        git = [
          vim-sleuth
          vim-fugitive
          vim-rhubarb
          diffview-nvim
        ];
        core = [
          # telescope
          telescope-fzf-native-nvim
          plenary-nvim
          telescope-nvim
          # treesitter
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars
          # (nvim-treesitter.withPlugins (
          #   plugins: with plugins; [
          #     nix
          #     lua
          #   ]
          # ))
          nvim-lspconfig
          fidget-nvim
          lualine-nvim
          marks-nvim
          vim-repeat
          comment-nvim
          indent-blankline-nvim
          gitsigns-nvim
        ];
        other = [
          nvim-web-devicons
          conform-nvim
          which-key-nvim
          nvim-surround
          eyeliner-nvim
          undotree
          nui-nvim
          neo-tree-nvim
        ];
      };
    };

    optionalPlugins = {
      customPlugins = with pkgs.nixCatsBuilds; [ ];
      gitPlugins = with pkgs.neovimPlugins; [ ];
      general = with pkgs.vimPlugins; [ ];
    };

    environmentVariables = {
      test = {
        BIRDTVAR = "It worked!";
      };
    };

    extraWrapperArgs = {
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      test = [
        '' --set BIRDTVAR2 "It worked again!"''
      ];
    };

  };

  # just to select the right thing out of bitwarden. 
  # Don't get excited its just a UUID
  bitwardenItemIDs = {
    codeium = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
    cody = "notes d0bddbff-ec1f-4151-a2a7-b0c20134eb34";
  };

  packageDefinitions = {
    minimal = { pkgs, ... }: {settings = { wrapRc = false; }; categories = {};};
    birdeeVim = { pkgs, ... }@misc: {
      settings = {
        wrapRc = true;
        # so that it finds my ai auths in ~/.cache/birdeevim
        configDirName = "birdeevim";
        withNodeJs = true;
        withRuby = true;
        extraName = "";
        withPython3 = true;
        aliases = [ "vim" "vi" ];
      };
      categories = {
        inherit bitwardenItemIDs;
        bitwarden = true;
        generalBuildInputs = true;
        bash = true;
        debug = true;
        customPlugins = true;
        general = true;
        neonixdev = true;
        AI = true;
        java = true;
        kotlin = true;
        test = true;
        lspDebugMode = false;
        colorscheme = "onedark";
      };
    };
    notesVim = { pkgs, ... }@misc: {
      settings = {
        configDirName = "birdeevim";
        wrapRc = true;
        withNodeJs = true;
        viAlias = false;
        vimAlias = false;
        aliases = [ "note" ];
      };
      categories = {
        inherit bitwardenItemIDs;
        bitwarden = true;
        generalBuildInputs = true;
        bash = true;
        debug = true;
        customPlugins = true;
        general = true;
        neonixdev = true;
        AI = true;
        java = true;
        kotlin = true;
        test = true;
        lspDebugMode = false;
        colorscheme = "tokyonight";
      };
    };
    noAInvim = { pkgs, ... }@misc: {
      settings = {
        configDirName = "birdeevim";
        wrapRc = true;
        withNodeJs = false;
        viAlias = false;
        vimAlias = false;
        aliases = [ "vi" "vim" ];
      };
      categories = {
        generalBuildInputs = true;
        bash = true;
        debug = true;
        customPlugins = true;
        general = true;
        neonixdev = true;
        java = true;
        kotlin = true;
        test = true;
        lspDebugMode = false;
        colorscheme = "catppuccin";
      };
    };
  };
in
  # see :help nixCats.flake.outputs.exports
  inputs.flake-utils.lib.eachDefaultSystem (system: let
    inherit (utils) baseBuilder;
    customPackager = baseBuilder luaPath {
      inherit (inputs) nixpkgs;
      inherit system dependencyOverlays extra_pkg_config;
    } categoryDefinitions;
    nixCatsBuilder = customPackager packageDefinitions;
    # this is just for using utils such as pkgs.mkShell
    # The one used to build neovim is resolved inside the builder
    # and is passed to our categoryDefinitions and packageDefinitions
    pkgs = import inputs.nixpkgs { inherit system; };
  in {
    # this will make a package out of each of the packageDefinitions defined above
    # and set the default package to the one named here.
    packages = utils.mkPackages nixCatsBuilder packageDefinitions "birdeeVim";

    # this will make an overlay out of each of the packageDefinitions defined above
    # and set the default overlay to the one named here.
    overlays = utils.mkOverlays nixCatsBuilder packageDefinitions "birdeeVim";

    # choose your package for devShell
    # and add whatever else you want in it.
    devShell = pkgs.mkShell {
      name = "birdeeVim";
      packages = [ (nixCatsBuilder "birdeeVim") ];
      inputsFrom = [ ];
      shellHook = ''
      '';
    };

    # To choose settings and categories from the flake that calls this flake.
    # and you export overlays so people dont have to redefine stuff.
    inherit customPackager;
  }
) // {
  # we also export a nixos module to allow configuration from configuration.nix
  nixosModules.default = utils.mkNixosModules {
    defaultPackageName = "birdeeVim";
    inherit (inputs) nixpkgs;
    inherit dependencyOverlays luaPath categoryDefinitions packageDefinitions;
  };
  # and the same for home manager
  homeModule = utils.mkHomeModules {
    defaultPackageName = "birdeeVim";
    inherit (inputs) nixpkgs;
    inherit dependencyOverlays luaPath categoryDefinitions packageDefinitions;
  };
  # now we can export some things that can be imported in other
  # flakes, WITHOUT needing to use a system variable to do it.
  # and update them into the rest of the outputs returned by the
  # eachDefaultSystem function.
  inherit utils dependencyOverlays categoryDefinitions packageDefinitions;
  inherit (utils) templates baseBuilder;
  keepLuaBuilder = utils.baseBuilder luaPath;
}
