{ ... }: with builtins; rec {
  mkScriptAliases = packageSet: concatStringsSep "\n" (mapAttrs (name: value: ''
      ${name}() {
        ${value}/bin/${name} "$@"
      }
  '') packageSet);
}
