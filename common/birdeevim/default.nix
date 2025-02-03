{inputs, birdeeutils, flake-path ? "/home/birdee/birdeeSystems", ... }@attrs: let
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

  categoryDefinitions = { pkgs, settings, categories, name, extra, mkNvimPlugin, ... }@packageDef: {

    extraCats = {
      notes = [
        [ "telescope" ]
      ];
    };

    environmentVariables = {
      test = {
        BIRDTVAR = "It worked!";
      };
    };
    sharedLibraries = {};
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
    extraWrapperArgs = {};

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
        (py.pylint.overrideAttrs { doCheck = false; })
        # python-lsp-ruff
        # pyls-flake8
        # pylsp-rope
        # yapf
        # autopep8
      ]);
    };

    # populates $LUA_PATH and $LUA_CPATH
    extraLuaPackages = {
      # vimagePreview = [ (lp: with lp; [ magick ]) ];
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
          lazygit
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
      ] ++ (if categories.kotlin or false then [] else []);
      kotlin = [
        kotlin-language-server
        ktlint
      ] ++ (if categories.java or false then [] else []);
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
        (extra.rust.toolchain or inputs.fenix.packages.${system}.latest.toolchain)
        rustup
        llvmPackages.bintools
        lldb
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
      theme = builtins.getAttr (extra.colorscheme or "onedark") {
        "onedark" = onedark-nvim;
        "catppuccin" = catppuccin-nvim;
        "catppuccin-mocha" = catppuccin-nvim;
        "tokyonight" = tokyonight-nvim;
        "tokyonight-day" = tokyonight-nvim;
      };
      general = [
        lze
        oil-nvim
        vim-repeat
        pkgs.neovimPlugins.nvim-luaref
        nvim-nio
        nui-nvim
        nvim-web-devicons
        nvim-notify
        plenary-nvim
        mini-nvim
        snacks-nvim
      ];
      other = [
        nvim-spectre
        # (pkgs.neovimUtils.grammarToPlugin (pkgs.tree-sitter-grammars.tree-sitter-nu.overrideAttrs (p: { installQueries = true; })))
      ];
      lua = [
        luvit-meta
      ];
      rust = [
        inputs.rustaceanvim.packages.${pkgs.system}.default
      ];
      neonixdev = [
        luvit-meta
      ];
      treesitter = builtins.attrValues pkgs.vimPlugins.nvim-treesitter.grammarPlugins;
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
        otter-nvim
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
      other = [
        img-clip-nvim
        nvim-highlight-colors
        nvim-neoclip-lua
        which-key-nvim
        eyeliner-nvim
        todo-comments-nvim
        vim-startuptime
        grapple-nvim
        pkgs.neovimPlugins.hlargs
        pkgs.neovimPlugins.visual-whitespace
      ];
      treesitter = [
        nvim-treesitter-textobjects
        nvim-treesitter
      ];
      telescope = [
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        pkgs.neovimPlugins.telescope-git-file-history
      ];
      general = with pkgs.neovimPlugins; {
        markdown = [
          render-markdown-nvim
          markdown-preview-nvim
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
        core = [
          vim-rhubarb
          vim-fugitive
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
    # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
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
    vimagePreview = true;
    lspDebugMode = false;
    other = true;
    theme = true;
    debug = true;
    customPlugins = true;
    general = true;
    telescope = true;
    otter = true;
    bash = true;
    notes = true;
    treesitter = true;
    neonixdev = true;
    java = true;
    web = true;
    go = true;
    kotlin = true;
    python = true;
    rust = true;
    SQL = true;
    C = true;
  };
  birdeevim_extra = { pkgs, ... }@misc: {
    colorscheme = "onedark";
    javaExtras = {
      java-test = pkgs.vscode-extensions.vscjava.vscode-java-test;
      java-debug-adapter = pkgs.vscode-extensions.vscjava.vscode-java-debug;
      gradle-ls = pkgs.vscode-extensions.vscjava.vscode-gradle;
    };
    nixdExtras = {
      nixpkgs = inputs.nixpkgsNV.outPath;
      flake-path = inputs.self.outPath;
      system = pkgs.system;
      systemCFGname = "birdee@nestOS";
      homeCFGname = "birdee@nestOS";
    };
    AIextras = {
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
  };

  packageDefinitions = {
    birdeeVim = args: {
      settings =  birdeevim_settings args // {
        wrapRc = true;
        aliases = [ "vi" "nvim" ];
      };
      categories =  birdeevim_categories args // {
      };
      extra = birdeevim_extra args // {
      };
    };
    nightlytest = { pkgs, ... }@args: {
      settings = birdeevim_settings args // {
        wrapRc = false;
        aliases = [ "tvim" ];
        neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
      };
      categories = birdeevim_categories args // {
        test = true;
        notes = true;
        lspDebugMode = true;
      };
      extra = birdeevim_extra args // {
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
      extra = birdeevim_extra args // {
      };
    };
    vigo = { pkgs, ... }@args: {
      settings = birdeevim_settings args // {
        wrapRc = true;
        extraName = "vigo";
        # aliases = [ "vigo" ];
      };
      categories = {
        theme = true;
        other = true;
        debug = true;
        customPlugins = true;
        general = true;
        telescope = true;
        treesitter = true;
        otter = true;
        nix = true;
        web = true;
        go = true;
        SQL = true;
      };
      extra = {
        inherit (birdeevim_extra args) nixdExtras;
      };
    };
    nvim_for_u = { pkgs, ... }@args: {
      settings = birdeevim_settings args // {
        wrapRc = true;
        extraName = "nvim_for_u";
        aliases = [ "vi" "vim" "nvim" ];
      };
      categories = birdeevim_categories args // {
        AI = false;
        tabCompletionKeys = true;
      };
      extra = birdeevim_extra args // {
        AIextras = null;
      };
    };
    noAInvim = { pkgs, ... }@args: {
      settings = birdeevim_settings args // {
        wrapRc = true;
        extraName = "noAInvim";
        aliases = [ "vi" "vim" "nvim" ];
      };
      categories = birdeevim_categories args // {
        AI = false;
      };
      extra = birdeevim_extra args // {
        AIextras = null;
      };
    };
    notesVim = { pkgs, ... }@args: {
      settings = birdeevim_settings args // {
        configDirName = "birdeevim";
        withRuby = false;
        extraName = "notesVim";
        aliases = [ "note" ];
      };
      categories = {
        notes = true;
        otter = true;
        customPlugins = true;
        other = true;
        general = true;
        neonixdev = true;
        telescope = true;
        treesitter = true;
        vimagePreview = true;
        AI = true;
        lspDebugMode = false;
        theme = true;
      };
      extra = birdeevim_extra args // {
        colorscheme = "tokyonight";
        javaExtras = null;
      };
    };
    portableVim = { pkgs, ... }@args: {
      settings = birdeevim_settings args // {
        extraName = "portableVim";
        aliases = [ "vi" "vim" "nvim" ];
      };
      categories = birdeevim_categories args // {
        portableExtras = true;
        notes = true;
        AI = false;
      };
      extra = birdeevim_extra args // {
        AIextras = null;
      };
    };
    minimalVim = { pkgs, ... }@args: {
      settings = birdeevim_settings args // {
        wrapRc = false;
        aliases = null;
        extraName = "minimalVim";
        withNodeJs = false;
        withRuby = false;
        withPython3 = false;
      };
      categories = {};
      extra = {};
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
    moduleNamespace = [ "birdeeMods" defaultPackageName ];
  };
  homeModule = utils.mkHomeModules {
    inherit nixpkgs;
    inherit defaultPackageName dependencyOverlays luaPath categoryDefinitions packageDefinitions;
    moduleNamespace = [ "birdeeMods" defaultPackageName ];
  };
}
