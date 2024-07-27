{ APPNAME
, lib
, makeWrapper
, stdenv
, ...
# override overrides these args
}: let
  APPDRV = stdenv.mkDerivation {
    # overrideAttrs overrides this set
    name = "${APPNAME}";
    src = ./src;
    buildInputs = [];
    nativeBuildInputs = [ makeWrapper ];
    buildPhase = ''
      runHook preBuild

      echo "build dir = $TEMPDIR/$sourceRoot"
      ls -la $TEMPDIR/$sourceRoot

      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      # install to $out/bin
      mkdir -p $out/bin
      mkdir -p $out/lib
      echo "build dir = $TEMPDIR/$sourceRoot"
      ls -la $TEMPDIR/$sourceRoot
      echo "cwd = $(pwd)"
      ls -la "$(pwd)"
      echo "out = $out"
      ls -la $out

      # make desktop file
      mkdir -p $out/share/applications
      cat > $out/share/applications/${APPNAME}.desktop <<EOFTAG
      [Desktop Entry]
      Type=Application
      Name=${APPNAME}
      Comment=Launches ${APPNAME}
      Terminal=false
      Exec=$out/bin/${APPNAME}
      EOFTAG
      runHook postInstall
    '';
    postFixup = ''
      wrapProgram $out/bin/${APPNAME} \
        --prefix PATH : ${lib.makeBinPath []} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath []}
    '';
    # passthru = { };
    meta = {
      mainProgram = APPNAME;
      description = "${APPNAME} is a program that does stuff";
      license = lib.licenses.mit;
      homepage = "https://github.com/BirdeeHub/${APPNAME}";
      maintainers = lib.mkIf (lib.maintainers ? birdee) [ lib.maintainers.birdee ];
    };
  };
in
APPDRV
