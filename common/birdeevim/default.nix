{inputs, flake-path ? "/home/birdee/birdeeSystems", ... }@attrs: let
  inherit (inputs.nixCats) utils;
  nixpkgs = inputs.nixpkgsNV;
  luaPath = "${./.}";
  forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
  extra_pkg_config = {
    allowUnfree = true;
  };
  dependencyOverlays = (import ./overlays inputs) ++ [
    (utils.sanitizedPluginOverlay inputs)
    # add any flake overlays here.
    inputs.neorg-overlay.overlays.default
    inputs.lze.overlays.default
    # inputs.neovim-nightly-overlay.overlays.default
    (utils.fixSystemizedOverlay inputs.codeium.overlays
      (system: inputs.codeium.overlays.${system}.default)
    )
  ];

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
          harper
        ];
      };
      AI = [
        bitwarden-cli
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
          # eslint
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
      theme = builtins.getAttr categories.colorscheme {
        "onedark" = onedark-nvim;
        "catppuccin" = catppuccin-nvim;
        "catppuccin-mocha" = catppuccin-nvim;
        "tokyonight" = tokyonight-nvim;
        "tokyonight-day" = tokyonight-nvim;
      };
      general = with pkgs.neovimPlugins; [
        lze
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
      treesitter = builtins.attrValues pkgs.vimPlugins.nvim-treesitter.grammarPlugins;
      other = [
        nvim-spectre
      ];
      lua = [
        luvit-meta
      ];
      neonixdev = [
        luvit-meta
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
      };
      other = with pkgs.neovimPlugins; [
        img-clip
        nvim-highlight-colors
        nvim-neoclip-lua
        which-key-nvim
        eyeliner-nvim
        todo-comments-nvim
        vim-startuptime
      ];
      treesitter = [
        nvim-treesitter-textobjects
        nvim-treesitter
      ];
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
      vimagePreview = [ (lp: with lp; [ magick ]) ];
    };
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
  AIextras = pkgs: {
    codeium_bitwarden_uuid = "notes d9124a28-89ad-4335-b84f-b0c20135b048";
    # NOTE: codeium table gets deep extended into codeium settings.
    codeium = {
      tools = {
        uname = "${pkgs.coreutils}/bin/uname";
        uuidgen = "${pkgs.util-linux}/bin/uuidgen";
        curl = "${pkgs.curl}/bin/curl";
        gzip = "${pkgs.gzip}/bin/gzip";
        language_server = "${inputs.codeium.packages.${pkgs.system}.codeium-lsp}/bin/codeium-lsp";
      };
    };
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
    # neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (prev: {
    #   preConfigure = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    #     substituteInPlace src/nvim/CMakeLists.txt --replace "    util" ""
    #   '';
    #   treesitter-parsers = {};
    # });
    # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim.overrideAttrs (prev: {
    #   preConfigure = pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
    #     substituteInPlace src/nvim/CMakeLists.txt --replace "    util" ""
    #   '';
    #   treesitter-parsers = {};
    # });
  };
  birdeevim_categories = { pkgs, ... }@misc: {
    AI = true;
    AIextras = AIextras pkgs;
    vimagePreview = true;
    lspDebugMode = false;
    generalBuildInputs = true;
    other = true;
    theme = true;
    colorscheme = "onedark";
    debug = true;
    customPlugins = true;
    general = true;
    otter = true;
    bash = true;
    notes = true;
    treesitter = true;
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
        aliases = [ "vi" "nvim" ];
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
        other = true;
        debug = true;
        customPlugins = true;
        general = true;
        treesitter = true;
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
        aliases = [ "vi" "vim" "nvim" ];
      };
      categories = birdeevim_categories misc // {
        AI = false;
        AIextras = false;
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
        notes = true;
        otter = true;
        generalBuildInputs = true;
        customPlugins = true;
        other = true;
        general = true;
        neonixdev = true;
        treesitter = true;
        nixdExtras = extraNixdItems pkgs;
        vimagePreview = true;
        AI = true;
        AIextras = AIextras pkgs;
        lspDebugMode = false;
        theme = true;
        colorscheme = "tokyonight";
      };
    };
    portableVim = { pkgs, ... }@misc: {
      settings = birdeevim_settings misc // {
        extraName = "portableVim";
        aliases = [ "vi" "vim" "nvim" ];
      };
      categories = birdeevim_categories misc // {
        portableExtras = true;
        notes = true;
        AI = false;
        AIextras = false;
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
    nixCatsBuilder = baseBuilder luaPath {
      inherit nixpkgs;
      inherit system dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
    pkgs = import nixpkgs { inherit system; };
  in {
    packages = utils.mkAllWithDefault defaultPackage;
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
}
