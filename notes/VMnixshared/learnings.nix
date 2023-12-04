builtins.derivation {
  name = "my-derivation";
  system = "x86_64-linux";
  builder = "/bin/sh";
  args = [ "-c" "echo Hello > $out" ];
}
