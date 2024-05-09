inputs: {
  overlayHub = inputs.nixCats.templates.overlayHub;
  overlayFile = inputs.nixCats.templates.overlayFile;
  gradle = {
    path = ./gradle;
    description = "hopefully a working gradle shell?";
  };
  flakeSchema = {
    path = ./flakeSchema;
    description = "an empty flake schema copy paste";
  };
  emptyFlake = {
    path = ./emptyFlake;
    description = "an empty flake";
  };
  helloC = {
    path = ./helloC;
    description = "an C empty flake that is probably not how you are meant to do it at all plz send help";
  };
  hx-gotempl = {
    path = ./hx-gotempl;
    description = "an empty go + templ + htmx flake template";
  };
  pythonshell-untested = {
    path = ./pythonshell-untested;
    description = ''a python shell I got from a reddit comment,
                  I have not tried it yet.
                  no idea if it works.'';
  };
}
