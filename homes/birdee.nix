{ config, util, pkgs, lib, inputs, users, username, output-name, stateVersion, osConfig ? null, ...  }@args: let
in {
  birdeeMods = {
    bash.enable = true;
    fish.enable = true;
    flatpak.enable = true;
    firefox.enable = true;
    i3.enable = true;
    i3.updateDbusEnvironment = true;
    i3MonMemory.enable = true;
    nixconfig.enable = true;
  };
  wrappers = {
    neovim.enable = true;
    wezterm.enable = true;
    zsh.enable = true;
    zsh.output-name = lib.mkIf (osConfig != null) output-name;
    zsh.home-output = if osConfig == null then output-name else username;
    zsh.hmSessionVariables = if osConfig == null then "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" else null;
    opencode.enable = true;
    tmux.enable = true;
    xplr.enable = true;
    git.enable = true;
    nushell.enable = true;
    luakit.enable = true;
  };

  home.sessionVariables.JAVA_HOME = "${pkgs.jdk}";

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
    extraConfig = {
      MISC = "${config.home.homeDirectory}/Misc";
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
    (config.wrappers.neovim.wrap { settings.test_mode = true; })
    nops # manix fzf alias
    dep-tree
    minesweeper
    antifennel
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
    # gccgo
    gotools
    go-tools
    sqlite-interactive
    evcxr

    clisp

    man-pages
    man-pages-posix
    _7zz
    # gnome.gnome-software
    steam
    heroic
    lutris
    wineWow64Packages.stable
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
    xev
    xmodmap
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
  gtk.gtk4.theme = config.gtk.theme;
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
