{inputs, flake-path ? "/home/birdee/birdeeSystems", ... }@attrs: let
  inherit (inputs.nixCats) utils;
  nixpkgs = inputs.nixpkgsNV;
  luaPath = "${./.}";
  forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
  extra_pkg_config = {
    allowUnfree = true;
  };
  inherit (forEachSystem (system: let
    dependencyOverlays = (import ./overlays inputs) ++ [
        (utils.sanitizedPluginOverlay inputs)
        # add any flake overlays here.
        inputs.neorg-overlay.overlays.default
        inputs.lz-n.overlays.default
        # inputs.neovim-nightly-overlay.overlays.default
      ] ++ (if (inputs.codeium.overlays ? system)
        then [ inputs.codeium.overlays.${system}.default ] else []);
  in { inherit dependencyOverlays; })) dependencyOverlays;

  categoryDefinitions = { pkgs, settings, categories, name, ... }@packageDef: {

    propagatedBuildInputs = {
      generalBuildInputs = with pkgs; [
      ];
    };

    sharedLibraries = {
      general = {
        git = with pkgs; [
          libgit2
        ];
      };
    };

    lspsAndRuntimeDeps = with pkgs; {
      portableExtras = [
        xclip
        wl-clipboard
        git
        nix
        coreutils-full
        curl
      ];
      general = {
        core = [
          universal-ctags
          ripgrep
          fd
          ast-grep
        ];
        other = [
          sqlite
        ];
        markdown = [
          marksman
          python311Packages.pylatexenc
        ];
      };
      bitwarden = [
        bitwarden-cli
      ];
      AI = with inputs; [
        codeium.packages.${system}.codeium-lsp
        sg-nvim.packages.${system}.default
      ];
      java = [
        jdt-language-server
      ] ++ (if categories ? kotlin && categories.kotlin then [] else []);
      kotlin = [
        kotlin-language-server
        ktlint
      ] ++ (if categories ? java && categories.java then [] else []);
      go = [
        gopls
        delve
        golint
        golangci-lint
        gotools
        go-tools
        go
      ];
      elixir = [
        elixir-ls
      ];
      web = {
        templ = with inputs; [
          templ.packages.${system}.templ
        ];
        tailwindcss = [
          tailwindcss-language-server
        ];
        HTMX = [
          htmx-lsp
        ];
        HTML = [
          vscode-langservers-extracted
        ];
        JS = with nodePackages; [
          typescript-language-server
          eslint
          prettier
        ];
      };
      rust = [
        rust-analyzer
      ];
      lua = [
        lua-language-server
      ];
      nix = [
        nix-doc
        nil
        nixd
        nixfmt-rfc-style
      ];
      neonixdev = [
        nix-doc
        nil
        lua-language-server
        nixd
        nixfmt-rfc-style
      ];
      vimagePreview = [
        imagemagick
        ueberzugpp
      ];
      bash = [
        nodePackages.bash-language-server
      ];
      python = with python311Packages; [
        # jedi-language-server
        python-lsp-server
        debugpy
        pytest
        # pylint
        # python-lsp-ruff
        # pyls-flake8
        # pylsp-rope
        # yapf
        # autopep8
      ];
      notes = [
      ];
      C = [
        clang-tools
        valgrind
        cmake-language-server
        cpplint
        cmake
        cmake-format
      ];
      SQL = [
      ];
    };

    startupPlugins = with pkgs.vimPlugins; {
      inherit lz-n;
      theme = builtins.getAttr categories.colorscheme {
        "onedark" = onedark-nvim;
        "catppuccin" = catppuccin-nvim;
        "catppuccin-mocha" = catppuccin-nvim;
        "tokyonight" = tokyonight-nvim;
        "tokyonight-day" = tokyonight-nvim;
      };
      general = with pkgs.neovimPlugins; [
        large_file
        oil-nvim
        vim-repeat
        nvim-luaref
        nvim-nio
        nui-nvim
        nvim-web-devicons
        nvim-notify
        plenary-nvim
        mini-nvim
      ];
    };

    optionalPlugins = with pkgs.vimPlugins; {
      SQL = [
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
      ];
      vimagePreview = [
        image-nvim
      ];
      C = [
        vim-cmake
        clangd_extensions-nvim
      ];
      python = [
        nvim-dap-python
      ];
      notes = [
        neorg
        neorg-telescope
      ];
      otter = [
        pkgs.neovimPlugins.otter-nvim
      ];
      go = [
        nvim-dap-go
      ];
      java = [
        nvim-jdtls
      ];
      neonixdev = [
        lazydev-nvim
      ];
      AI = [
        codeium-nvim
        inputs.sg-nvim.packages.${pkgs.system}.sg-nvim
      ];
      debug = [
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
      ];
      general = with pkgs.neovimPlugins; {
        markdown = [
          markdown-preview-nvim
        ];
        StdPlugOver = [
          grapple
          hlargs
          visual-whitespace
          render-markdown
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
          telescope-git-file-history
          fugit2-nvim
          nvim-tinygit
          dressing-nvim
          diffview-nvim
          vim-rhubarb
          vim-fugitive
        ];
        core = [
          # telescope
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
          gitsigns-nvim
          marks-nvim
          indent-blankline-nvim
          nvim-lint
          conform-nvim
          undotree
          nvim-surround
          treesj
          vim-sleuth
        ];
        other = [
          img-clip
          nvim-highlight-colors
          nvim-neoclip-lua
          which-key-nvim
          eyeliner-nvim
          todo-comments-nvim
          vim-startuptime
        ];
      };
    };

    environmentVariables = {
      test = {
        BIRDTVAR = "It worked!";
      };
    };

    extraWrapperArgs = {
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
      test = [
        # '' --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libgit2 ]}"''
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
        # py.python-lsp-black
        py.pytest
        py.pylint
        # python-lsp-ruff
        # pyls-flake8
        # pylsp-rope
        # yapf
        # autopep8
      ]);
    };
    # populates $LUA_PATH and $LUA_CPATH
    extraLuaPackages = {
      general = [ (lp: with lp; [ magick ]) ];
    };
  };

  # just to select the right thing out of bitwarden. 
  # Don't get excited its just a UUID
  # Also they arent valid anymore
  bitwardenItemIDs = {
    codeium = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
    cody = "notes d0bddbff-ec1f-4151-a2a7-b0c20134eb34";
  };
  extraJavaItems = pkgs: {
    java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
    java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
    gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
  };
  extraNixdItems = pkgs: {
    nixpkgs = inputs.nixpkgsNV.outPath;
    flake-path = inputs.self.outPath;
    system = pkgs.system;
    systemCFGname = "birdee@nestOS";
    homeCFGname = "birdee@nestOS";
  };

  birdeevim_settings = { pkgs, ... }@misc: {
    # so that it finds my ai auths in ~/.cache/birdeevim
    extraName = "birdeevim";
    configDirName = "birdeevim";
    wrapRc = true;
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    viAlias = false;
    vimAlias = false;
    gem_path = ./overlays/ruby_provider;
    unwrappedCfgPath = "${flake-path}/common/birdeevim";
    # nvimSRC = inputs.neovim-src;
    # neovim-unwrapped = pkgs.internalvim.nvim;
    neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
    # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
  };
  birdeevim_categories = { pkgs, ... }@misc: {
    inherit bitwardenItemIDs;
    bitwarden = true;
    AI = true;
    vimagePreview = true;
    lspDebugMode = false;
    generalBuildInputs = true;
    theme = true;
    colorscheme = "onedark";
    lz-n = true;
    debug = true;
    customPlugins = true;
    general = true;
    otter = true;
    bash = true;
    neonixdev = true;
    java = true;
    javaExtras = extraJavaItems pkgs;
    nixdExtras = extraNixdItems pkgs;
    web = true;
    go = true;
    kotlin = true;
    python = true;
    rust = true;
    SQL = true;
    C = true;
  };

  packageDefinitions = {
    birdeeVim = args: {
      settings =  birdeevim_settings args // {
        wrapRc = true;
        aliases = [ "vi" ];
      };
      categories =  birdeevim_categories args // {
      };
    };
    testvim = args: {
      settings = birdeevim_settings args // {
        wrapRc = false;
        aliases = [ "vim" ];
      };
      categories = birdeevim_categories args // {
        test = true;
        # notes = true;
        lspDebugMode = true;
      };
    };
    vigo = { pkgs, ... }@misc: {
      settings = birdeevim_settings misc // {
        wrapRc = true;
        extraName = "vigo";
        # aliases = [ "vigo" ];
      };
      categories = {
        generalBuildInputs = true;
        theme = true;
        colorscheme = "onedark";
        lz-n = true;
        debug = true;
        customPlugins = true;
        general = true;
        otter = true;
        nix = true;
        nixdExtras = extraNixdItems pkgs;
        web = true;
        go = true;
        SQL = true;
      };
    };
    noAInvim = { pkgs, ... }@misc: {
      settings = birdeevim_settings misc // {
        wrapRc = true;
        extraName = "noAInvim";
        aliases = [ "vi" "vim" ];
      };
      categories = birdeevim_categories misc // {
        AI = false;
        bitwardenItemIDs = false;
        bitwarden = false;
      };
    };
    notesVim = { pkgs, ... }@misc: {
      settings = birdeevim_settings misc // {
        configDirName = "birdeevim";
        withRuby = false;
        extraName = "notesVim";
        aliases = [ "note" ];
      };
      categories = {
        inherit bitwardenItemIDs;
        notes = true;
        otter = true;
        bitwarden = true;
        generalBuildInputs = true;
        customPlugins = true;
        general = true;
        neonixdev = true;
        nixdExtras = extraNixdItems pkgs;
        vimagePreview = true;
        AI = true;
        lspDebugMode = false;
        lz-n = true;
        theme = true;
        colorscheme = "tokyonight";
      };
    };
    portableVim = { pkgs, ... }@misc: {
      settings = birdeevim_settings misc // {
        extraName = "portableVim";
        aliases = [ "vi" "vim" ];
      };
      categories = birdeevim_categories misc // {
        portableExtras = true;
        notes = true;
        AI = false;
        bitwardenItemIDs = false;
        bitwarden = false;
      };
    };
    minimalVim = { pkgs, ... }@misc: {
      settings = birdeevim_settings misc // {
        wrapRc = false;
        aliases = null;
        extraName = "minimalVim";
        withNodeJs = false;
        withRuby = false;
        withPython3 = false;
      };
      categories = {};
    };
  };

  defaultPackageName = "birdeeVim";
in
  forEachSystem (system: let
    inherit (utils) baseBuilder;
    customPackager = baseBuilder luaPath {
      inherit nixpkgs;
      inherit system dependencyOverlays extra_pkg_config;
    } categoryDefinitions;
    nixCatsBuilder = customPackager packageDefinitions;
    pkgs = import nixpkgs { inherit system; };
  in {
    packages = utils.mkPackages nixCatsBuilder packageDefinitions defaultPackageName;
    app-images = {
      portableVim = inputs.nix-appimage.bundlers.${system}.default (nixCatsBuilder "portableVim");
    };
    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ (nixCatsBuilder defaultPackageName) ];
        inputsFrom = [ ];
        DEVSHELL = 0;
        shellHook = ''
          exec ${pkgs.zsh}/bin/zsh
        '';
      };
    };

    inherit customPackager;
  }
) // {
  overlays = utils.makeOverlaysWithMultiDefault luaPath {
    inherit nixpkgs dependencyOverlays extra_pkg_config;
  } categoryDefinitions packageDefinitions defaultPackageName;
  nixosModules.default = utils.mkNixosModules {
    inherit nixpkgs;
    inherit defaultPackageName dependencyOverlays luaPath categoryDefinitions packageDefinitions;
  };
  homeModule = utils.mkHomeModules {
    inherit nixpkgs;
    inherit defaultPackageName dependencyOverlays luaPath categoryDefinitions packageDefinitions;
  };
  inherit utils dependencyOverlays categoryDefinitions packageDefinitions;
  inherit (utils) templates baseBuilder;
  keepLuaBuilder = utils.baseBuilder luaPath;
}
