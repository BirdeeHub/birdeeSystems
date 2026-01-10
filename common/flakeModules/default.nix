inputs: let
  inherit (inputs.nixpkgs.lib.modules) importApply;
in {
  hub = importApply ./hub.nix inputs;
  configsPerSystem = importApply ./configsPerSystem.nix inputs;
  wrapper = importApply ./wrapper.nix inputs;
}
