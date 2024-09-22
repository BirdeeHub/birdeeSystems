{ config, lib, pkgs, self, modulesPath, system-modules, inputs, is_minimal ? true, use_alacritty ? true, ... }: let
  # TODO: non_minimal should also include calamares installer, i3, firefox,
  # and also disk utilities so that you dont have to nix shell them all

  tx = pkgs.writeShellScriptBin "tx" ''
    if ! echo "$PATH" | grep -q "${pkgs.tmux}/bin"; then
      export PATH=${pkgs.tmux}/bin:$PATH
    fi
    if [[ $(tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
      selected_session=$(tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
      exec tmux new-session -At $selected_session
    else
      exec tmux new-session
    fi
  '';
  nerd_font_string = "FiraMono";
  font_string = "${nerd_font_string} Nerd Font";
  login_shell = "zsh";

in {
  imports = with system-modules; [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ./minimal-graphical-base.nix
    shell.${login_shell}
    ranger
  ] ++ (lib.optional (login_shell != "bash") system-modules.shell.bash);

  birdeeMods = {
    ${login_shell}.enable = true;
    ranger = {
      enable = true;
      withoutDragon = true;
    };
  } // (lib.optionalAttrs (login_shell != "bash") {
    bash.enable = true;
  });

  environment.systemPackages = with pkgs; [
    inputs.disko.packages.${system}.default
    tmux
    tx
    git
    findutils
    coreutils
    xclip
  ] ++ (if is_minimal then [
    pkgs.neovim
  ] else with pkgs; [
    # todo make a version that counts as minimal to include above
    system-modules.birdeeVim.packages.${system}.noAInvim
  ]);

  isoImage.isoBaseName = "birdeeOS_installer";
  isoImage.contents = lib.mkIf (builtins.isPath "${self}/secrets") [
    { source = "${self}/secrets"; target = "/secrets";}
  ];

  environment.shellAliases = let
  in {
    birdeeOS = "${pkgs.writeShellScript "birdeeOS" ''
      output=$1
      username=$2
      sudo disko --mode disko --flake github:BirdeeHub/birdeeSystems#$output
      sudo nixos-install --show-trace --flake github:BirdeeHub/birdeeSystems#$output
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username/birdeeSystems
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/$username/birdeeSystems
      sudo chmod -R go-rwx /mnt/home/$username/birdeeSystems
      sudo chown -R $username:users /mnt/home/$username/birdeeSystems
    ''}";
    birdeeOS-disko = "${pkgs.writeShellScript "birdeeOS-disko" ''
      output=$1
      sudo disko --mode disko --flake github:BirdeeHub/birdeeSystems#$output
    ''}";
    birdeeOS-install = "${pkgs.writeShellScript "birdeeOS-install" ''
      output=$1
      username=$2
      sudo nixos-install --show-trace --flake github:BirdeeHub/birdeeSystems#$output
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username/birdeeSystems
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/$username/birdeeSystems
      sudo chmod -R go-rwx /mnt/home/$username/birdeeSystems
      sudo chown -R $username:users /mnt/home/$username/birdeeSystems
    ''}";
    lsnc = "ls --color=never";
    la = "ls -a";
    ll = "ls -l";
    l  = "ls -alh";
  };

  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = true;

  users.defaultUserShell = pkgs.${login_shell};
  system.activationScripts.silencezsh.text = ''
    [ ! -e "/home/nixos/.zshrc" ] && echo "# dummy file" > /home/nixos/.zshrc
  '';

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = lib.optionals (nerd_font_string != "") [ nerd_font_string ]; })
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ font_string ];
      sansSerif = [ font_string ];
      monospace = [ font_string ];
    };
  };
  fonts.fontDir.enable = true;

  services.xserver.enable = true;
  services.displayManager.defaultSession = if use_alacritty then "alacritty" else "xterm-installer";
  services.xserver.desktopManager.session = let
    alacritty_dm = (let
      alakitty = pkgs.callPackage ./alatoml.nix {
        maximizer = "${inputs.maximizer.packages.${pkgs.system}.default}/bin/maximize_program";
        inherit tx font_string;
        shellStr = "${pkgs.${login_shell}}/bin/${login_shell}";
      };
    in [
      { name = "alacritty";
        start = /*bash*/ ''
          ${pkgs.alacritty}/bin/alacritty --config-file ${alakitty} &
          waitPID=$!
        '';
      }
    ]);
    xterm_dm = (let
      maximizer = "${inputs.maximizer.packages.${pkgs.system}.default}/bin/maximize_program";
      launchScript = pkgs.writeShellScript "mysh" /*bash*/ ''
        ${maximizer} xterm > /dev/null 2>&1 &
        exec ${tx}/bin/tx
      '';
    in [
      { name = "xterm-installer";
        start = /*bash*/ ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge ${pkgs.writeText "Xresources" ''
            xterm*termName: xterm-256color
            xterm*faceName: ${font_string}
            xterm*faceSize: 12
            xterm*background: black
            xterm*foreground: white
            xterm*title: xterm
            xterm*loginShell: true
          ''}
          ${pkgs.xterm}/bin/xterm -name xterm -e ${launchScript} &
          waitPID=$!
        '';
      }
    ]);
  in
  if use_alacritty then alacritty_dm else xterm_dm;

}
