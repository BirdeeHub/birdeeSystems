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
