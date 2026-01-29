{ lib, wlib }: rec {
  collectOptions = import ./collectOptions.nix lib;
  normDocs = import ./normopts.nix { inherit wlib lib collectOptions; };
  renderVal =
    v:
    if v ? _type && v ? text then
      if v._type == "literalExpression" then "`${toString v.text}`" else toString v.text
    else if lib.isStringLike v && !builtins.isString v then
      v.name or builtins.unsafeDiscardStringContext "${v}"
    else
      v;
}
