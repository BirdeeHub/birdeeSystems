importName: inputs: final: prev: let
  pkgs = import inputs.nixpkgs-ollama { inherit (prev) system; };
  drv = {
    symlinkJoin,
    opencode,
    makeBinaryWrapper,
    lib,
    ...
  }: symlinkJoin {
    name = "opencode";
    paths = [ opencode ];
    nativeBuildInputs = [ makeBinaryWrapper ];
    postBuild = let
      jsonfile = builtins.toFile "opencode.json" /*json*/''
        {
          "$schema": "https://opencode.ai/config.json",
          "provider": {
            "ollama": {
              "npm": "@ai-sdk/openai-compatible",
              "name": "Ollama (local)",
              "options": {
                "baseURL": "http://localhost:11434/v1"
              },
              "models": {
                "gpt-oss:20b": {
                  "name": "gpt-oss:20b"
                },
                "qwen3:14b": {
                  "name": "qwen3:14b"
                },
                "qwen3:8b": {
                  "name": "qwen3:8b"
                }
              }
            }
          }
        }
      '';
      wrapperArgs = [
        "--set-default" "OPENCODE_CONFIG" "${jsonfile}"
      ];
    in ''
      wrapProgram "$out/bin/opencode" ${lib.escapeShellArgs wrapperArgs}
    '';
  };
  in {
  opencode = pkgs.callPackage drv { opencode = pkgs.opencode; };
}
