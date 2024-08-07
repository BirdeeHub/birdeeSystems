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
  overlayHub = inputs.nixCats.templates.overlayHub;
  overlayFile = inputs.nixCats.templates.overlayFile;
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
  lua-fenster = {
    path = ./lua-fenster;
    description = "a lua environment with fenster built in it";
  };
  flakescript = {
    path = ./flakescript;
    description = "a tiny flake that outputs an overlay and a package containing a shell script";
  };
  pythonshell-untested = {
    path = ./pythonshell-untested;
    description = ''a python shell I got from a reddit comment,
                  I have not tried it yet.
                  no idea if it works.'';
  };
}
