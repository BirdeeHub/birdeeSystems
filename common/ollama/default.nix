isHomeModule: { config, pkgs, self, inputs, lib, overlays ? [], users, ... }: let
  inherit (lib) types;

  cfg = config.birdeeMods.ollama;
  ollamaPackage= cfg.package.override {
    inherit (cfg) acceleration;
    linuxPackages = config.boot.kernelPackages // {
      nvidia_x11 = config.hardware.nvidia.package;
    };
  };
in {
  options = {
     birdeeMods.ollama = {
      enable = lib.mkEnableOption "Enable Ollama";
      package = lib.mkPackageOption pkgs "ollama" { };
      home = lib.mkOption {
        type = types.str;
        default = "%S/ollama";
        example = "/home/foo";
        description = ''
          The home directory that the ollama service is started in.
        '';
      };
      models = lib.mkOption {
        type = types.str;
        default = "%S/ollama/models";
        example = "/path/to/ollama/models";
        description = ''
          The directory that the ollama service will read models from and download new models to.
        '';
      };
      listenAddress = lib.mkOption {
        type = types.str;
        default = "127.0.0.1:11434";
        example = "0.0.0.0:11111";
        description = ''
          The address which the ollama server HTTP interface binds and listens to.
        '';
      };
      acceleration = lib.mkOption {
        type = types.nullOr (types.enum [ "rocm" "cuda" ]);
        default = null;
        example = "rocm";
        description = ''
          What interface to use for hardware acceleration.

          - `rocm`: supported by modern AMD GPUs
          - `cuda`: supported by modern NVIDIA GPUs
        '';
      };
      environmentVariables = lib.mkOption {
        type = types.attrsOf types.str;
        default = { };
        example = {
          HOME = "/tmp";
          OLLAMA_LLM_LIBRARY = "cpu";
        };
        description = ''
          Set arbitrary environment variables for the ollama service.

          Be aware that these are only seen by the ollama server (systemd service),
          not normal invocations like `ollama run`.
          Since `ollama run` is mostly a shell around the ollama server, this is usually sufficient.
        '';
      };
    };
  };
  config = lib.mkIf config.birdeeMods.ollama.enable (let
    cfg = config.birdeeMods.ollama;
  in if isHomeModule == true then {
    # TODO: Make this work
    home.packages = [ ollamaPackage ];
    systemd.user.services.ollama = {
      Unit = {
        Description = "Server for local large language models";
        After = [ "network.target" ];
      };
      Install.WantedBy = [ "network.target" ];
      environment = cfg.environmentVariables // {
        HOME = cfg.home;
        OLLAMA_MODELS = cfg.models;
        OLLAMA_HOST = cfg.listenAddress;
      };
      Service = {
        ExecStart = "${lib.getExe ollamaPackage} serve";
        WorkingDirectory = "%S/ollama";
        StateDirectory = [ "ollama" ];
        DynamicUser = true;
      };
    };
  } else {
    systemd.services.ollama = {
      description = "Server for local large language models";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment = cfg.environmentVariables // {
        HOME = cfg.home;
        OLLAMA_MODELS = cfg.models;
        OLLAMA_HOST = cfg.listenAddress;
      };
      serviceConfig = {
        ExecStart = "${lib.getExe ollamaPackage} serve";
        WorkingDirectory = "%S/ollama";
        StateDirectory = [ "ollama" ];
        DynamicUser = true;
      };
    };

    environment.systemPackages = [ ollamaPackage ];
  });
}
