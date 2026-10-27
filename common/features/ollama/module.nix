{ inputs, moduleNamespace, ... }:
let
  name = "ollama";
in
{
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
      loadModels = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      acceleration = lib.mkOption {
        type = lib.types.enum [ "cuda" "rocm" ];
        default = "rocm";
      };
      rocmVersion = lib.mkOption {
        type = lib.types.str;
        default = "11.0.2";
      };
    };
    config = lib.mkIf cfg.enable {
      services.ollama = {
        enable = true;
        acceleration = lib.mkIf (cfg.acceleration == "cuda") "cuda";
        rocmOverrideGfx = lib.mkIf (cfg.acceleration == "rocm") cfg.rocmVersion;
        package = pkgs.ollama;
        environmentVariables = lib.mkIf (cfg.acceleration == "rocm") {
          DRI_PRIME = toString 1;
        };
        # package = (import inputs.nixpkgs-ollama { inherit (pkgs) overlays; inherit (pkgs.stdenv.hostPlatform) system; }).ollama.overrideAttrs {
        #   src = inputs.ollama;
        #   version = "0.11.3";
        #   vendorHash = "sha256-SlaDsu001TUW+t9WRp7LqxUSQSGDF1Lqu9M1bgILoX4=";
        # };
        loadModels = cfg.loadModels;
      };
      systemd.tmpfiles.rules = lib.mkIf (cfg.acceleration == "rocm") [
        "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
      ];
    };
  };
}
