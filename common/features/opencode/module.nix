{ inputs, ... }:
{
  flake.wrappers.opencode =
    {
      config,
      pkgs,
      wlib,
      lib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.opencode ];
      package = pkgs.opencode.overrideAttrs {
        node_modules = pkgs.opencode.node_modules.overrideAttrs {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        };
      };
      settings = {
        "$schema" = "https://opencode.ai/config.json";
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama (local)";
            options = {
              baseURL = "http://10.0.0.101:11434/v1";
            };
            models = {
              "qwen3.6:35b-a3b" = {
                name = "qwen3.6:35b-a3b";
              };
              "qwen3.5:122b" = {
                name = "qwen3.5:122b";
              };
            };
          };
        };
      };
    };
}
