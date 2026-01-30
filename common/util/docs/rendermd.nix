{
  wlib,
  lib,
  normWrapperDocs,
}:
{
  options,
  graph,
  nameFromModule ? { file, ... }: toString file,
  ...
}:
let
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
    ## ${opt.name or ""}

    ${opt.description or ""}

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

      <details open>
        <summary></summary>

      ${lib.pipe (mod.visible or [ ]) [
        (map renderOption)
        (builtins.concatStringsSep "\n\n")
      ]}

      </details>
    '';
in
builtins.concatStringsSep "\n\n" (map renderModule cleaned)
