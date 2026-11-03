{ lib, config, pkgs, util, inputs, ... }: let
  name = "installer";
  cfg = config.${util.moduleNamespace}.${name};
  birdeeOS = "${pkgs.writeShellScriptBin "birdeeOS" ''
    target=''${1:-${lib.escapeShellArg cfg.defaultScriptTarget}}
    username=""
    [[ "$target" == *@* ]] && username="''${target%%@*}"
    repo="github:BirdeeHub/birdeeSystems"
    sudo nix run "$repo#diskoConfigurations.$target"
    sudo nixos-install --flake "$repo#$target"
    if [[ "$username" != "" ]]; then
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
    fi
  ''}";
in {
  options.${util.moduleNamespace}.${name} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable ${name} options";
    };
    prebakedConfigs = lib.mkOption {
      default = [];
      type = lib.types.listOf lib.types.str;
    };
    installScripts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "enable personal installer scripts";
    };
    defaultScriptTarget = lib.mkOption {
      type = lib.types.str;
      default = "birdee@nestOS";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkIf cfg.installScripts [
      birdeeOS
    ];
    isoImage.storeContents = builtins.concatMap (TC: let
      lpout = inputs.self.legacyPackages.${pkgs.stdenv.hostPlatform.system} or null;
      nixosCfg = lpout.nixosConfigurations.${TC} or null;
      activationscript = nixosCfg.config.system.build.toplevel or null;
      diskoWrapper = lpout.diskoConfigurations.${TC} or null;
    in lib.optional (activationscript != null) activationscript ++ lib.optional (diskoWrapper != null) diskoWrapper) cfg.prebakedConfigs;
    image.baseName = lib.mkForce "birdeeOS_installer";
  };
}
