{ config, pkgs, wlib, lib, ... }: {
  imports = [ wlib.wrapperModules.opencode ];
  settings = {
    "$schema" = "https://opencode.ai/config.json";
    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "Ollama (local)";
        options = {
          baseURL = "http://localhost:11434/v1";
        };
        models = {
          "gpt-oss:20b" = {
            name = "gpt-oss:20b";
          };
          "qwen3:14b" = {
            name = "qwen3:14b";
          };
          "qwen3:8b" = {
            name = "qwen3:8b";
          };
        };
      };
    };
  };
}
