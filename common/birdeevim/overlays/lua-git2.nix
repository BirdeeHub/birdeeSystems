# In your flake inputs, you would add:
# inputs.luagit2-src = {
#   url = "github:libgit2/luagit2";
#   flake = false
# };

# call with:
# import ./thisfile.nix "lua-git2" inputs;

importName: inputs: let
  luagit2 = { src, buildLuarocksPackage, luaOlder }:
    buildLuarocksPackage {
      pname = "lua-git2";
      version = "scm-0";
      inherit src;
      disabled = luaOlder "5.1";
      meta = {
        homepage = "https://github.com/libgit2/luagit2";
        description = "LibGit2 bindings for Lua.";
        license.fullName = "MIT";
      };
    };
  overlay = self: super: let
    pkgs = import inputs.nixpkgs {  inherit (self) system; };
  in {
    # will create pkgs.${importName}
    ${importName} = pkgs.callPackage luagit2 { src = inputs.luagit2-src; };
  };
in
overlay
