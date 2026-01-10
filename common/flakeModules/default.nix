inputs: let
  inherit (inputs.nixpkgs.lib.modules) importApply;
in {
  misc = importApply ./misc.nix inputs;
  overlay = importApply ./overlay.nix inputs;
  configsPerSystem = importApply ./configsPerSystem.nix inputs;
  wrapper = importApply ./wrapper.nix inputs;
}
