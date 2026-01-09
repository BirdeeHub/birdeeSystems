{ inputs, ... }: {
  hub = import ./hub.nix inputs;
  configsPerSystem = import ./configsPerSystem.nix inputs;
}
