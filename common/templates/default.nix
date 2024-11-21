inputs: {
  default = {
    path = ./flakeParts;
    description = "an empty flake with flake parts";
  };
  flakeParts = {
    path = ./flakeParts;
    description = "an empty flake with flake parts";
  };
  emptyFlake = {
    path = ./emptyFlake;
    description = "an empty flake";
  };
  gradle = {
    path = ./gradle;
    description = "hopefully a working gradle shell?";
  };
  android = {
    path = ./android;
    description = "hopefully a working android shell?";
  };
  flakeSchema = {
    path = ./flakeSchema;
    description = "an empty flake schema copy paste";
  };
  helloC = {
    path = ./helloC;
    description = "an C empty flake that is probably not how you are meant to do it at all plz send help";
  };
  hx-gotempl = {
    path = ./hx-gotempl;
    description = "an empty go + templ + htmx flake template";
  };
  crabby = {
    path = ./crabby;
    description = "helloworld rust with nix flake";
  };
  lua-fenster = {
    path = ./lua-fenster;
    description = "a lua environment with fenster built in it";
  };
  luaFlake = {
    path = ./luaFlake;
    description = "an empty flake for a compiled lua application";
  };
  flakescript = {
    path = ./flakescript;
    description = "a tiny flake that outputs an overlay and a package containing a shell script";
  };
  simplest = {
    path = ./simplest;
    description = "simplest flake possible as example to link probably";
  };
  nvim_bug_report = {
    path = ./nvim_bug_report;
    description = "nixCatsless nvim template for nixpkgs bug reports that loads a dir";
  };
  nvim_bug_report_min = {
    path = ./nvim_bug_report_min;
    description = "minimal nixCatsless nvim template for nixpkgs bug reports";
  };
  pythonshell-untested = {
    path = ./pythonshell-untested;
    description = ''a python shell I got from a reddit comment,
                  I have not tried it yet.
                  no idea if it works.'';
  };
}
