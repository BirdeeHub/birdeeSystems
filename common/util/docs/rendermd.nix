{
  wlib,
  lib,
  normWrapperDocs,
}:
{
  options,
  graph,
  includeCore ? true,
  transform ? x: if builtins.elem "_module" x.loc then [ ] else [ x ],
  nameFromModule ?
    { file, ... }:
    lib.removeSuffix "/module.nix" (lib.removePrefix "${wlib.modulesPath}/" (toString file)),
  moduleStartsOpen ? i: mod: i == 1,
  descriptionStartsOpen ?
    type: i: mod:
    i == 1,
  extraModuleNotes ?
    i:
    { maintainers, ... }:
    lib.optionalString (maintainers != [ ] && i == 1) (
      "This module is made possible by: " + builtins.concatStringsSep ", " (map (v: v.name) maintainers)
    ),
  declaredBy ?
    { declarations, ... }:
    let
      linkDest =
        v:
        if lib.hasPrefix wlib.modulesPath v then
          "https://github.com/BirdeeHub/nix-wrapper-modules/blob/main"
          + lib.removePrefix wlib.modulesPath (toString v)
        else
          toString v;
      linkName = v: lib.removeSuffix "/module.nix" (lib.removePrefix "${wlib.modulesPath}/" (toString v));
    in
    builtins.concatStringsSep "\n" (map (v: "- [${linkName v}](${linkDest v})") declarations),
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
      builtins.unsafeDiscardStringContext (
        if v._type == "literalExpression" then "```nix\n${toString v.text}\n```" else toString v.text
      )
    else if lib.isStringLike v && !builtins.isString v then
      builtins.unsafeDiscardStringContext "`<${if v ? name then "derivation ${v.name}" else v}>`"
    else if builtins.isString v then
      builtins.unsafeDiscardStringContext v
    else if builtins.isList v then
      map sanitize v
    else if lib.isFunction v then
      builtins.unsafeDiscardStringContext "`<function with arguments ${
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
  normed = normWrapperDocs { inherit options graph transform; };
  maybecore = if includeCore == true then normed else builtins.filter (v: v.file != wlib.core) normed;
  cleaned = lib.reverseList (sanitize maybecore);
  renderOption = opt: ''
    ## `${lib.options.showOption (opt.loc or [ ])}`

    ${
      lib.optionalString (opt.description or "" != "") ''
        ${opt.description}

      ''
    }${
      lib.optionalString (opt ? relatedPackages) ''
        Related packages:
        ${opt.relatedPackages}

      ''
    }${
      lib.optionalString (opt ? type) ''
        Type:
        ${opt.type}

      ''
    }${
      lib.optionalString (opt ? default) ''
        Default:
        ${opt.default}

      ''
    }${
      lib.optionalString (opt.example or "" != "") ''
        Example:
        ${opt.example}

      ''
    }${
      lib.optionalString (opt.declarations or [ ] != [ ]) ''
        Declared by:

        ${declaredBy opt}

      ''
    }
  '';
  renderModule =
    i: mod:
    let
      moduleNotes = extraModuleNotes i mod;
    in
    lib.optionalString (mod.visible or [ ] != [ ]) ''
      ## ${nameFromModule mod}
      ${lib.optionalString (builtins.isString moduleNotes && moduleNotes != "") "\n${moduleNotes}\n"}
      ${lib.optionalString (mod.description.pre or "" != "") ''
        <details${if descriptionStartsOpen "pre" i mod then " open" else ""}>
          <summary></summary>

        ${mod.description.pre}

        </details>

      ''}
      ${lib.optionalString (mod.visible or [ ] != [ ]) ''
        <details${if moduleStartsOpen i mod then " open" else ""}>
          <summary></summary>

        ${lib.pipe mod.visible [
          (map renderOption)
          (builtins.concatStringsSep "\n\n")
        ]}

        </details>
      ''}
      ${lib.optionalString (mod.description.post or "" != "") ''

        <details${if descriptionStartsOpen "post" i mod then " open" else ""}>
          <summary></summary>

        ${mod.description.post}

        </details>
      ''}
    '';
in
builtins.unsafeDiscardStringContext (
  builtins.concatStringsSep "\n\n" (lib.imap1 renderModule cleaned)
)
