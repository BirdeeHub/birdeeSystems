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
        ktlint
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
      htmx = with pkgs; [
        htmx-lsp
        # TODO: html lsp executable not found, but its building SOMETHING
        html-lsp
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
        nodePackages.bash-language-server
        bashdb # a bash debugger. seemed like an easy first debugger to add, and would be useful
        pkgs.nixCatsBuilds.bash-debug-adapter # I unfortunately need to build it I think... IDK how yet.
      ];
      python = with pkgs.python311Packages; [
        # jedi-language-server
        python-lsp-server
        debugpy
        pytest
        pylint
        # python-lsp-ruff
        # pyls-flake8
        # pylsp-rope
        # yapf
        # autopep8
      ];
      notes = with pkgs; [
      ];
      C = with pkgs; [
        clang-tools
        valgrind
        cmake-language-server
        cpplint
        cmake
        cmake-format
      ];
    };

    startupPlugins = {
      C = with pkgs.vimPlugins; [
        vim-cmake
        clangd_extensions-nvim
      ];
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
          grapple
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
    # :!nvim-python3
    extraPython3Packages = {
      python = (py:[
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
    extraPythonPackages = {
      python = (_:[]);
    };
    # populates $LUA_PATH and $LUA_CPATH
    extraLuaPackages = {
      lua = [ (_:[]) ];
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

  birdeevim_settings = { pkgs, ... }@misc: {
    # so that it finds my ai auths in ~/.cache/birdeevim
    extraName = "birdeevim";
    configDirName = "birdeevim";
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    viAlias = false;
    vimAlias = false;
    neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
  };
  birdeevim_categories = { pkgs, ... }@misc: {
    inherit bitwardenItemIDs;
    bitwarden = true;
    generalBuildInputs = true;
    bash = true;
    debug = true;
    customPlugins = true;
    general = true;
    neonixdev = true;
    htmx = true;
    AI = true;
    java = true;
    javaExtras = extraJavaItems pkgs;
    go = true;
    kotlin = true;
    C = true;
    lspDebugMode = false;
    colorscheme = "onedark";
  };

  packageDefinitions = {
    notesVim = { pkgs, ... }@misc: {
      settings = {
        configDirName = "birdeevim";
        withRuby = false;
        extraName = "notesVim";
        aliases = [ "note" ];
      } // birdeevim_settings misc;
      categories = {
        inherit bitwardenItemIDs;
        notes = true;
        bitwarden = true;
        generalBuildInputs = true;
        customPlugins = true;
        general = true;
        neonixdev = true;
        AI = true;
        lspDebugMode = false;
        colorscheme = "tokyonight";
      };
    };
    birdeeVim = args: {
      settings = {
        wrapRc = true;
        aliases = [ "vi" ];
      } // birdeevim_settings args;
      categories = {
        python = true;
      } // birdeevim_categories args;
    };
    testvim = args: {
      settings = {
        wrapRc = false;
        aliases = [ "vim" ];
      } // birdeevim_settings args;
      categories = {
        test = true;
        # notes = true;
        lspDebugMode = true;
      } // birdeevim_categories args;
    };
    noAInvim = { pkgs, ... }@misc: {
      settings = {
        wrapRc = true;
        withNodeJs = true;
        extraName = "noAInvim";
        aliases = [ "vi" "vim" ];
      } // birdeevim_settings misc;
      categories = {
        AI = false;
        bitwardenItemIDs = false;
        bitwarden = false;
      } // birdeevim_categories misc;
    };
    minimalVim = { pkgs, ... }@misc: {
      settings = {
        wrapRc = false;
        aliases = null;
        extraName = "minimalVim";
        withNodeJs = false;
        withRuby = false;
        withPython3 = false;
      } // birdeevim_settings misc;
      categories = {};
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
      DEVSHELL = 0;
      shellHook = ''
        exec ${pkgs.zsh}/bin/zsh
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
