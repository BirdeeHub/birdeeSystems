# Copyright (c) 2023 BirdeeHub 
# Licensed under the MIT license 
{inputs, ... }@attrs:
inputs.flake-utils.lib.eachDefaultSystem (system: let
  inherit (inputs) nixpkgs nixCats;
  inherit (nixCats) utils;
  systemPkgs = attrs.pkgs;

  dependencyOverlays = [ (utils.mergeOverlayLists nixCats.dependencyOverlays.${system}
  ((import ./overlays inputs) ++ [
    (utils.standardPluginOverlay inputs)
    # add any flake overlays here.
    inputs.codeium.overlays.${system}.default
  ])) ];
  pkgs = import nixpkgs {
    inherit system;
    overlays = dependencyOverlays;
    # config.allowUnfree = true;
  };

  inherit (utils) baseBuilder;
  nixCatsBuilder = baseBuilder "${./.}" { inherit pkgs dependencyOverlays; } categoryDefinitions packageDefinitions;

  categoryDefinitions = packageDef: {

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
        theme = builtins.getAttr packageDef.categories.colorscheme { 
          "onedark" = onedark-vim;
          "catppuccin" = catppuccin-nvim;
          "catppuccin-mocha" = catppuccin-nvim;
          "tokyonight" = tokyonight-nvim;
          "tokyonight-day" = tokyonight-nvim;
        };
        markdown = with pkgs.vimPlugins; [
          pkgs.nixCatsBuilds.markdown-preview-nvim
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
    minimal = {settings = { wrapRc = false; }; categories = {};};
    birdeeVim = {
      settings = {
        wrapRc = true;
        # so that it finds my ai auths in ~/.cache/birdeevim
        configDirName = "birdeevim";
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withRuby = true;
        extraName = "";
        withPython3 = true;
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
    notesVim = {
      settings = {
        configDirName = "birdeevim";
        wrapRc = true;
        withNodeJs = true;
        viAlias = false;
        vimAlias = false;
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
    noAI = {
      settings = {
        configDirName = "birdeevim";
        wrapRc = true;
        withNodeJs = false;
        viAlias = false;
        vimAlias = true;
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
        colorscheme = "onedark";
      };
    };
  };
in
{
  packages = (builtins.mapAttrs (name: _: nixCatsBuilder name) packageDefinitions);

  overlays = utils.mkExtraOverlays nixCatsBuilder packageDefinitions "birdeeVim";

  devShell = pkgs.mkShell {
    name = "birdeeVim";
    packages = [ (nixCatsBuilder "birdeeVim") ];
    inputsFrom = [ ];
    shellHook = ''
    '';
  };

  # To choose settings and categories from the flake that calls this flake.
  customPackager = baseBuilder "${./.}" { inherit pkgs dependencyOverlays;} categoryDefinitions;

  # and you export this so people dont have to redefine stuff.
  inherit dependencyOverlays;
  inherit categoryDefinitions;
  inherit packageDefinitions;

  # we also export a nixos module to allow configuration from configuration.nix
  nixosModules.default = utils.mkNixosModules {
    defaultPackageName = "birdeeVim";
    luaPath = "${./.}";
    inherit dependencyOverlays
      categoryDefinitions packageDefinitions;
  };
  # and the same for home manager
  homeModule = utils.mkHomeModules {
    defaultPackageName = "birdeeVim";
    luaPath = "${./.}";
    inherit dependencyOverlays
      categoryDefinitions packageDefinitions;
  };
})

