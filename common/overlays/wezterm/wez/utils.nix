with builtins; rec {
# https://github.com/BirdeeHub/nixCats-nvim/blob/3bdf5eb044af49dbcc0cc542319a334bc2605773/nix/builder/ncTools.nix#L4-L46
  luaTablePrinter = attrSet: let
    luatableformatter = attrSet: let
      nameandstringmap = mapAttrs (n: value: let
          name = ''[ [[${n}]] ]'';
        in
        if value == true then "${name} = true"
        else if value == false then "${name} = false"
        else if value == null then "${name} = nil"
        else if lib.isDerivation value then "${name} = [[${value}]]"
        else if isList value then "${name} = ${luaListPrinter value}"
        else if isAttrs value then "${name} = ${luaTablePrinter value}"
        else "${name} = [[${toString value}]]"
      ) attrSet;
      resultList = attrValues nameandstringmap;
      resultString = concatStringsSep ", " resultList;
    in
    resultString;
    catset = luatableformatter attrSet;
    LuaTable = "{ " + catset + " }";
  in
  LuaTable;

  luaListPrinter = theList: let
    lualistformatter = theList: let
      stringlist = map (value:
        if value == true then "true"
        else if value == false then "false"
        else if value == null then "nil"
        else if lib.isDerivation value then "[[${value}]]"
        else if isList value then "${luaListPrinter value}"
        else if isAttrs value then "${luaTablePrinter value}"
        else "[[${toString value}]]"
      ) theList;
      resultString = concatStringsSep ", " stringlist;
    in
    resultString;
    catlist = lualistformatter theList;
    LuaList = "{ " + catlist + " }";
  in
  LuaList;

  lib = {
    isDerivation = value: value.type or null == "derivation";
  };
}
