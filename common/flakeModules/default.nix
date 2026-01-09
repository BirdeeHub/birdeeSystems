{ inputs, ... }: {
  hub = import ./hub.nix inputs;
  configsPerSystem = import ./configsPerSystem.nix inputs;
  wrapper = import ./wrapper.nix inputs;
}
