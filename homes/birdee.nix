{ config, pkgs, self, inputs, users, username, stateVersion, home-modules, monitorCFG, ...  }@args: let
in {
  imports = with home-modules; [
    term.alacritty
    term.tmux
    shell.bash
    shell.zsh
    shell.fish
    firefox
    birdeeVim.module
    ranger
    thunar
    i3
    i3MonMemory
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = users.homeManager.${username}.homeDirectory;
  programs.git = users.git.${username};

  birdeeVim = {
    enable = true;
    packageNames = [ "birdeeVim" "notesVim" ];
  };
  birdeeMods = {
    zsh.enable = true;
    bash.enable = true;
    fish.enable = true;
    alacritty.enable = true;
    tmux.enable = true;
    firefox.enable = true;
    thunar.enable = true;
    ranger = {
      enable = true;
    };
    i3.enable = true;
    i3.tmuxDefault = true;
    i3MonMemory.enable = true;
    i3MonMemory.monitorScriptDir = monitorCFG;
  };

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "-d";
  };

  home.shellAliases = {
    flakeUpAndAddem = ''${pkgs.writeShellScript "flakeUpAndAddem.sh" (/*bash*/''
      target=""; [[ $# > 0 ]] && target=".#$1" && shift 1;
      git add . && nix flake update && nix build --show-trace $target && git add .; $@
    '')}'';
    spkgname = ''${pkgs.writeShellScript "searchCLIname" (/*bash*/''
      ${pkgs.nix-search-cli}/bin/nix-search -n "$@"
    '')}'';
    spkgprog = ''${pkgs.writeShellScript "searchCLIprog" (/*bash*/''
      ${pkgs.nix-search-cli}/bin/nix-search -q  "package_programs:("$@")"
    '')}'';
    spkgdesc = ''${pkgs.writeShellScript "searchCLIdesc" (/*bash*/''
      ${pkgs.nix-search-cli}/bin/nix-search -q  "package_description:("$@")"
    '')}'';
    ls = "lsd";
    la = "lsd -a";
    ll = "lsd -l";
    l  = "lsd -alh";
    yeet = "rm -rf";
    run = "nohup xdg-open";
  };
  home.sessionVariables = {
    EDITOR = "birdeeVim";
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    JAVA_HOME = "${pkgs.jdk}";
  };

  nix.registry = {
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
    "inode/directory" = [ "ranger.desktop" ];
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
  home.packages = let
  in
  with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    openmoji-color
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraMono" "Go-Mono" ]; })

    vlc
    xfce.ristretto
    qbittorrent
    galculator
    gparted
    ntfs3g
    exfatprogs
    lm_sensors
    psensor
    btop
    graphviz-nox
    nix-output-monitor
    nix-info
    direnv
    steam-run
    # qemu
    # lxappearance
    qalculate-qt
    signal-desktop
    bitwarden-cli
    discord
    jdk
    gradle
    kotlin
    kotlin-native
    docker-compose
    peek
    gnumake
    cmake
    # gccgo

    go
    gotools
    go-tools
    sqlite-interactive

    _7zz
    # flatpak
    # gnome.gnome-software
    steam
    heroic
    lutris
    wine
    # wine64
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
    gimp
    spotify
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
    git
    pciutils
    xclip
    xsel
    xorg.xev
    xorg.xmodmap
    libreoffice
    wireshark
    chromium
    slack
    zoom-us
    remmina
    ventoy-full

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  fonts.fontconfig.enable = true;
  qt.platformTheme = "gtk";
  qt.enable = true;
  qt.style.package = pkgs.adwaita-qt;
  qt.style.name = "adwaita-dark";
  gtk.enable = true;

  gtk.cursorTheme.package = pkgs.phinger-cursors;
  gtk.cursorTheme.name = "phinger-cursors";

  home.pointerCursor.package = pkgs.phinger-cursors;
  home.pointerCursor.name = "phinger-cursors";

  gtk.theme.package = pkgs.adw-gtk3;
  gtk.theme.name = "adw-gtk3-dark";

  # gtk.gtk3.extraCss = '''';
  # gtk.gtk3.extraConfig = {};
  # gtk.gtk4.extraCss = '''';
  # gtk.gtk4.extraConfig = {};

  gtk.iconTheme.package = pkgs.beauty-line-icon-theme;
  gtk.iconTheme.name = "BeautyLine";

  programs.bash.enableVteIntegration = true;
  programs.zsh.enableVteIntegration = true;
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

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
