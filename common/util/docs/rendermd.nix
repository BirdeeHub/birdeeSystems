{
  wlib,
  lib,
  normWrapperDocs,
}:
{
  options,
  graph,
  nameFromModule ? { file, ... }: lib.removeSuffix "/module.nix" (lib.removePrefix "${wlib.modulesPath}/" (toString file)),
  moduleStartsOpen ? { file, ... }: file != wlib.core,
  ...
}:
let
/*
  Backslash (\)
  Backtick (`)
  Asterisk (*)
  Underscore (_)
  Curly braces ({})
  Square brackets ([])
  Angle brackets (<>)
  Parentheses (())
  Pound sign/Hash mark (#)
  Plus sign (+)
  Minus sign/Hyphen (-)
  Dot (.)
  Exclamation mark (!)
  Pipe (|) (used in tables in some Markdown flavors) 
*/
  sanitize =
    v:
    if v ? _type && v ? text then
      if v._type == "literalExpression" then "```\n${toString v.text}\n```" else toString v.text
    else if lib.isStringLike v && !builtins.isString v then
      builtins.unsafeDiscardStringContext "`<${if v ? name then "derivation ${v.name}" else v}>`"
    else if builtins.isString v then
      builtins.unsafeDiscardStringContext v
    else if builtins.isList v then
      map sanitize v
    else if lib.isFunction v then
      "`<function with arguments ${
        lib.pipe v [
          lib.functionArgs
          (lib.mapAttrsToList (n: v: "${n}${lib.optionalString v "?"}"))
          (builtins.concatStringsSep ", ")
        ]
      }>`"
    else if builtins.isAttrs v then
      builtins.mapAttrs (n: sanitize) v
    else
      v;
  normed = normWrapperDocs { inherit options graph; };
  cleaned = lib.reverseList (sanitize normed);
  renderOption = opt: ''
    ## `${opt.name or ""}`

    ${lib.optionalString (opt ? description) ''
      ${opt.description}

    ''}
    ${lib.optionalString (opt ? relatedPackages) ''
      related packages:
      ${opt.relatedPackages}

    ''}
    ${lib.optionalString (opt ? type) ''
      type:
      ${opt.type}

    ''}
    ${lib.optionalString (opt ? default) ''
      default:
      ${opt.default}

    ''}
    ${lib.optionalString (opt ? example) ''
      example:
      ${opt.example}

    ''}
  '';
  renderModule =
    mod:
    lib.optionalString (mod.visible or [ ] != [ ]) ''
      # ${nameFromModule mod}

      <details${if moduleStartsOpen mod then " open" else ""}>
        <summary></summary>

      ${lib.pipe (mod.visible or [ ]) [
        (map renderOption)
        (builtins.concatStringsSep "\n\n")
      ]}

      </details>
    '';
in
builtins.concatStringsSep "\n\n" (map renderModule cleaned)
