{inputs, ... }@attrs: let
  inherit (inputs.nixCats) utils;
  luaPath = "${./.}";
  forEachSystem = inputs.flake-utils.lib.eachSystem inputs.flake-utils.lib.allSystems;
  extra_pkg_config = {
    allowUnfree = true;
  };
  inherit (forEachSystem (system: let
    dependencyOverlays = [ (utils.mergeOverlayLists inputs.nixCats.dependencyOverlays.${system}
      ((import ./overlays inputs) ++ [
        (utils.standardPluginOverlay inputs)
        # add any flake overlays here.
        inputs.neorg-overlay.overlays.default
      ] ++ (if (inputs.codeium.overlays ? system)
        then [ inputs.codeium.overlays.${system}.default ] else [])
    )) ];
  in { inherit dependencyOverlays; })) dependencyOverlays;

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
      ] ++ (if categories.java then [] else [
      ]);
      go = with pkgs; [
        gopls
        delve
        golint
        gotools
        go-tools
        go
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
        nix-doc
        nil
        lua-language-server
        nixd
      ];
      bash = with pkgs; [
        bashdb # a bash debugger. seemed like an easy first debugger to add, and would be useful
        pkgs.nixCatsBuilds.bash-debug-adapter # I unfortunately need to build it I think... IDK how yet.
      ];
      python = with pkgs.python311Packages; [
        # jedi-language-server
        python-lsp-server
        debugpy
        pytest
        pylint
        # NOTE: check if these actually have bin folders
        # currently they are commented out though, unsure if I want them
        # but if no bin folder, add to extraPython3packages instead
        # python-lsp-ruff
        # pyls-flake8
        # pylsp-rope
        # yapf
        # autopep8
      ];
      notes = with pkgs; [
      ];
    };

    startupPlugins = {
      python = with pkgs.vimPlugins; [
        nvim-dap-python
      ];
      notes = with pkgs.vimPlugins; [
        neorg
        neorg-telescope
        otter-nvim
      ];
      go = with pkgs.vimPlugins; [
        nvim-dap-go
      ];
      java = with pkgs.vimPlugins; [
        nvim-jdtls
      ];
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
          plenary-nvim
          telescope-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
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
          lualine-lsp-progress
          lualine-nvim
          marks-nvim
          vim-repeat
          comment-nvim
          indent-blankline-nvim
          gitsigns-nvim
          nvim-lint
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
          treesj
          oil-nvim
          todo-comments-nvim
        ];
      };
    };

    optionalPlugins = {
      customPlugins = with pkgs.nixCatsBuilds; [ ];
      gitPlugins = with pkgs.neovimPlugins; [ ];
      general = with pkgs.vimPlugins; [ ];
      notes = with pkgs.vimPlugins; [ ];
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

    # python.withPackages or lua.withPackages
    # vim.g.python3_host_prog
    extraPythonPackages = {
      test = (_:[]);
    };
    extraPython3Packages = {
      test = (py:[
        py.debugpy
        py.pylsp-mypy
        py.pyls-isort
        py.python-lsp-server
        py.python-lsp-black
        py.pytest
        py.pylint
        # python-lsp-ruff
        # pyls-flake8
        # pylsp-rope
        # yapf
        # autopep8
      ]);
    };
    extraLuaPackages = {
      test = [ (_:[]) ];
    };

  };

  # just to select the right thing out of bitwarden. 
  # Don't get excited its just a UUID
  bitwardenItemIDs = {
    codeium = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
    cody = "notes d0bddbff-ec1f-4151-a2a7-b0c20134eb34";
  };
  extraJavaItems = pkgs: {
    java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
    java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
    gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
  };

  packageDefinitions = {
    minimalVim = { pkgs, ... }: {
      settings = {
        nvimSRC = inputs.neovim;
        wrapRc = false;
        aliases = [ ];
      };
      categories = {};
    };
    birdeeVim = { pkgs, ... }@misc: {
      settings = {
        wrapRc = true;
        # so that it finds my ai auths in ~/.cache/birdeevim
        configDirName = "birdeevim";
        withNodeJs = true;
        nvimSRC = inputs.neovim;
        withRuby = true;
        extraName = "birdeevim";
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
        javaExtras = extraJavaItems pkgs;
        go = true;
        kotlin = true;
        python = true;
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
        nvimSRC = inputs.neovim;
        viAlias = false;
        vimAlias = false;
        aliases = [ "note" ];
      };
      categories = {
        inherit bitwardenItemIDs;
        notes = true;
        bitwarden = true;
        generalBuildInputs = true;
        bash = true;
        debug = true;
        customPlugins = true;
        general = true;
        neonixdev = true;
        AI = true;
        java = true;
        javaExtras = extraJavaItems pkgs;
        kotlin = true;
        python = true;
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
        nvimSRC = inputs.neovim;
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
        javaExtras = extraJavaItems pkgs;
        go = true;
        kotlin = true;
        python = true;
        test = true;
        lspDebugMode = false;
        colorscheme = "catppuccin";
      };
    };
  };

  defaultPackageName = "birdeeVim";
in
  forEachSystem (system: let
    inherit (utils) baseBuilder;
    customPackager = baseBuilder luaPath {
      inherit (inputs) nixpkgs;
      inherit system dependencyOverlays extra_pkg_config;
    } categoryDefinitions;
    nixCatsBuilder = customPackager packageDefinitions;
    pkgs = import inputs.nixpkgs { inherit system; };
  in {
    packages = utils.mkPackages nixCatsBuilder packageDefinitions defaultPackageName;

    overlays = utils.mkOverlays nixCatsBuilder packageDefinitions defaultPackageName;

    devShell = pkgs.mkShell {
      name = defaultPackageName;
      packages = [ (nixCatsBuilder defaultPackageName) ];
      inputsFrom = [ ];
      shellHook = ''
      '';
    };

    inherit customPackager;
  }
) // {
  nixosModules.default = utils.mkNixosModules {
    inherit (inputs) nixpkgs;
    inherit defaultPackageName dependencyOverlays luaPath categoryDefinitions packageDefinitions;
  };
  homeModule = utils.mkHomeModules {
    inherit (inputs) nixpkgs;
    inherit defaultPackageName dependencyOverlays luaPath categoryDefinitions packageDefinitions;
  };
  inherit utils dependencyOverlays categoryDefinitions packageDefinitions;
  inherit (utils) templates baseBuilder;
  keepLuaBuilder = utils.baseBuilder luaPath;
}
