{ moduleNamespace, inputs, ... }:
let
  module =
    {
      config,
      pkgs,
      lib,
      _class,
      ...
    }:
    let
      cfg = config.${moduleNamespace}.bash;
      _file = ./bash.nix;
      options = {
        ${moduleNamespace}.bash = {
          enable = lib.mkEnableOption "birdeeBash";
        };
      };
      fzfinit = pkgs.runCommand "fzfinit" { } "${pkgs.fzf}/bin/fzf --bash > $out";
      # https://github.com/nix-community/home-manager/blob/82ce401aa350502897c3f2e85f384d61cd3b0b6d/modules/misc/vte.nix#L31-L51
      vte = ''
        __HM_PROMPT_COMMAND="''${PROMPT_COMMAND:+''${PROMPT_COMMAND%;};}__hm_vte_prompt_command"
        . ${pkgs.vte}/etc/profile.d/vte.sh
        if [[ $(type -t __vte_prompt_command) = function ]]; then
          __hm_vte_prompt_command() {
            local old_exit_status=$?
            __vte_prompt_command
            return $old_exit_status
          }
          PROMPT_COMMAND="$__HM_PROMPT_COMMAND"
        fi
        unset __HM_PROMPT_COMMAND
      '';
      init = ''
        . ${config.wrappers.starship.wrap { shell = "bash"; }}/bin/starship
        export "PATH=${pkgs.carapace}/bin:$PATH"
        export CARAPACE_BRIDGES='bash,inshellisense' # optional
        source <(${pkgs.carapace}/bin/carapace _carapace bash)
        source ${fzfinit}
      '';
    in
    {
      hjem = {
        inherit _file options;
        config = lib.mkIf cfg.enable {
          files.".bashrc".text = init + "\n" + vte;
        };
      };
      homeManager = {
        inherit _file options;
        config = lib.mkIf cfg.enable {
          home.packages = [ pkgs.carapace ];
          programs.bash = {
            enable = true;
            enableVteIntegration = true;
            initExtra = init;
          };
        };
      };
      nixos = {
        inherit _file options;
        config = lib.mkIf cfg.enable {
          environment.systemPackages = [ pkgs.carapace ];
          programs.bash = {
            enable = true;
            promptInit = init;
          };
        };
      };
    }
    .${_class};
in
{
  flake.modules.nixos.bash = module;
  flake.modules.homeManager.bash = module;
  flake.modules.hjem.bash = module;
}
