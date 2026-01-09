{ config, pkgs, lib, self, inputs, flake-path, users, username, stateVersion, home-modules, monitorCFG, osConfig ? null, ...  }@args: let
in {
  imports = with home-modules; [
    shell.bash
    shell.zsh
    shell.fish
    firefox
    birdeevim
    i3
    i3MonMemory
  ];

  birdeeMods = {
    birdeevim = {
      enable = true;
      packageNames = [ "birdeevim" "testvim" ];
    };
    zsh.enable = true;
    bash.enable = true;
    fish.enable = true;
    firefox.enable = true;
    i3.enable = true;
    i3.updateDbusEnvironment = true;
    i3MonMemory.enable = true;
    i3MonMemory.monitorScriptDir = monitorCFG;
  };

  home.shellAliases = let
    model = "qwen2.5-coder:7b";
    prompt = pkgs.writeShellScript "prompt" /*bash*/''
      model=''${1:-'${model}'}
      prompt='
      Generate a silly commit message. Follow these rules:

      Rules:
      - Output ONLY the message — no quotes, no formatting, no explanation.
      - Do NOT use any Twitter-style hashtags (#).
      - Do NOT start with "Refactored the code".
      - Do NOT wrap the reply in quotes, parentheses, or brackets.
      - The output should be raw, like: Fixed the flux capacitor again

      Now reply with just the message.'
      prompt=''${2:-$prompt}
      ollama run "$model" "$prompt"
      echo "(auto-msg $model)"
      ${pkgs.git_with_config}/bin/git status
    '';
  in {
    flakeUpAndAddem = ''${pkgs.writeShellScript "flakeUpAndAddem.sh" /*bash*/''
      target=""; [[ $# > 0 ]] && target=".#$1" && shift 1;
      git add . && nix flake update && nom build --show-trace $target && git add .; $@
    ''}'';
    spkgname = ''${pkgs.writeShellScript "searchCLIname" /*bash*/''
      ${pkgs.nix-search-cli}/bin/nix-search -n "$@"
    ''}'';
    spkgprog = ''${pkgs.writeShellScript "searchCLIprog" /*bash*/''
      ${pkgs.nix-search-cli}/bin/nix-search -q  "package_programs:("$@")"
    ''}'';
    spkgdesc = ''${pkgs.writeShellScript "searchCLIdesc" /*bash*/''
      ${pkgs.nix-search-cli}/bin/nix-search -q  "package_description:("$@")"
    ''}'';
    autorepl = ''${pkgs.writeShellScript "autorepl" ''
      exec nix repl --show-trace --expr '{ pkgs = import ${inputs.nixpkgs.outPath} { system = "${pkgs.system}"; config.allowUnfree = true; }; }' "$@"
    ''}'';
    yolo = ''${pkgs.git_with_config}/bin/git add . && ${pkgs.git_with_config}/bin/git commit -m "$(curl -fsSL https://whatthecommit.com/index.txt)" -m '(auto-msg whatthecommit.com)' -m "$(${pkgs.git_with_config}/bin/git status)" && ${pkgs.git_with_config}/bin/git push'';
    yoloAI = ''${pkgs.git_with_config}/bin/git add . && ${pkgs.git_with_config}/bin/git commit -m "$(${prompt})" && ${pkgs.git_with_config}/bin/git push'';
    ai-msg = ''${prompt}'';
    scratch = ''export OGDIR="$(realpath .)" && export SCRATCHDIR="$(mktemp -d)" && cd "$SCRATCHDIR"'';
    exitscratch = ''cd "$OGDIR" && rm -rf "$SCRATCHDIR"'';
    lsnc = "lsd --color=never";
    la = "lsd -a";
    ll = "lsd -lh";
    l  = "lsd -alh";
    yeet = "rm -rf";
    ccd = ''cd "$(${pkgs.xplr}/bin/xplr --print-pwd-as-result)"'';
    # Ok, so, this is not an alias, but I find it fun and I wanted to save it so its just a comment
    # bat(){ if [[ ! -t 0 || $# != 0 ]]; then local f; for f in "${@-/dev/stdin}"; do echo "$(<"$f")"; done; fi }
    dugood = ''${pkgs.writeShellScript "dugood" ''du -hxd1 $@ | sort -hr''}'';
    run = "nohup xdg-open";
    find-nix-roots = "${pkgs.writeShellScript "find-nix-roots" "find \"\${1:-.}\" -type l -lname '/nix/store/*'"}";

    me-build-system = ''${pkgs.writeShellScript "me-build-system" ''
      export NH_FLAKE="${flake-path}";
      exec ${self}/scripts/system "$@"
    ''}'';
    me-build-home = ''${pkgs.writeShellScript "me-build-home" ''
      export NH_FLAKE="${flake-path}";
      exec ${self}/scripts/home "$@"
    ''}'';
    me-build-both = ''${pkgs.writeShellScript "me-build-both" ''
      export NH_FLAKE="${flake-path}";
      exec ${self}/scripts/both "$@"
    ''}'';
  };
  home.sessionVariables = let
    nvimpkg = config.birdeevim.out.packages.birdeevim;
    nvimpath = "${nvimpkg}/bin/${nvimpkg.nixCats_packageName}";
  in {
    EDITOR = nvimpath;
    MANPAGER = "${nvimpath} +Man!";
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    JAVA_HOME = "${pkgs.jdk}";
  };

  nix.settings = {
    # bash-prompt-prefix = "✓";
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    flake-registry = "";
    show-trace = true;
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nix.extraOptions = ''
    !include /home/birdee/.secrets/gitoke
  '';
  nix.nixPath = [
    "nixpkgs=${builtins.path { path = inputs.nixpkgs; }}"
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "-d";
  };
  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    nixCats.flake = inputs.birdeevim.inputs.nixCats;
    wrappers.flake = inputs.wrappers;
    home-manager.flake = inputs.home-manager;
    birdeeSystems.flake = self;
    gomod2nix.to = {
      type = "github";
      owner = "nix-community";
      repo = "gomod2nix";
    };
  };

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
    extraConfig = {
      XDG_MISC_DIR = "${config.home.homeDirectory}/Misc";
    };
  };
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = [ "xplr.desktop" ];
    "application/pdf" = [ "firefox.desktop" "draw.desktop" "gimp.desktop" ];
  };
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = stateVersion; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # 
    nops # manix fzf alias
    dep-tree
    minesweeper
    antifennel
    wezterm
    opencode
    tmux
    xplr
    git_with_config
    nushell
    luakit
    gac
    nix-inspect
    #

    ffuf
    kdePackages.kdenlive
    blender
    kdePackages.dolphin
    nmap
    sqlmap
    burpsuite
    zap
    metasploit
    yt-dlp
    bettercap
    openvpn
    openconnect
    ghidra
    nth
    xh

    jimtcl

    fira-code
    nerd-fonts.fira-mono
    open-fonts
    xkcd-font
    openmoji-color
    noto-fonts-color-emoji
    nerd-fonts.go-mono

    # dislocker
    ueberzugpp
    vlc
    nix-tree
    ristretto
    grex
    qbittorrent
    # galculator
    gparted
    exfatprogs
    ntfs3g
    lm_sensors
    btop
    graphviz-nox
    nix-output-monitor
    nh
    manix
    inputs.nsearch.packages.${stdenv.hostPlatform.system}.default
    nix-info
    direnv
    steam-run
    # ruffle
    # qemu
    # lxappearance
    qalculate-qt
    signal-desktop
    bitwarden-cli
    discord
    docker-compose
    peek
    obs-studio
    obs-do
    obs-cli
    obs-cmd
    gnumake
    cmake
    # gccgo just have a dev shell for c....
    gccgo
    gotools
    go-tools
    sqlite-interactive
    evcxr

    clisp

    man-pages
    man-pages-posix
    _7zz
    # flatpak
    # gnome.gnome-software
    steam
    heroic
    lutris
    wineWowPackages.stable
    winetricks
    python3
    distrobox
    lazygit
    nix-search-cli
    fastfetch
    lolcat
    nurl
    gping
    
    nix-prefetch
    wget
    openssl
    gimp
    # spotify
    zsh
    tree
    fd
    fzf
    duf
    tldr
    lsof
    noti
    bat
    lsd
    zip
    dig
    unzip
    pciutils
    xclip
    xcp
    xsel
    xorg.xev
    xorg.xmodmap
    libreoffice
    wireshark
    chromium
    slack
    zoom-us
    remmina
    # ventoy-full

    # stinky
    jdk
    gradle
    kotlin
    kotlin-native
    # jetbrains.idea-community
    android-studio
    visualvm
  ];
  fonts.fontconfig.enable = true;

  home.pointerCursor.package = pkgs.phinger-cursors;
  home.pointerCursor.name = "phinger-cursors";
  home.pointerCursor.enable = true;
  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.x11.enable = true;
  home.pointerCursor.x11.defaultCursor = "phinger-cursors";
  home.pointerCursor.dotIcons.enable = true;

  gtk.theme.package = pkgs.adw-gtk3;
  gtk.theme.name = "adw-gtk3-dark";
  gtk.font.name = "Sans";
  gtk.font.size = 11;
  gtk.enable = true;

  qt.enable = true;
  qt.platformTheme.name = "gtk3";
  qt.style.package = pkgs.adwaita-qt;
  qt.style.name = "adwaita-qt";

  # gtk.gtk3.extraCss = '''';
  # gtk.gtk3.extraConfig = {};
  # gtk.gtk4.extraCss = '''';
  # gtk.gtk4.extraConfig = {};

  gtk.iconTheme.package = pkgs.beauty-line-icon-theme;
  gtk.iconTheme.name = "BeautyLine";

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # ".config/foo-dir".source = config.lib.file.mkOutOfStoreSymlink "apparently store or absolute is fine";
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/birdee/etc/profile.d/hm-session-vars.sh
  #

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
