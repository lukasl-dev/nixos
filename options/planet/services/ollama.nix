{ config, lib, ... }:

let
  nvidia = config.planet.hardware.nvidia;

  ollama = config.planet.services.ollama;
in
{
  options.planet.services.ollama = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable ollama";
      default = true;
      example = "true";
    };
  };

  config = lib.mkIf ollama.enable {
    services.ollama = {
      enable = true;

      acceleration = if nvidia.cuda then "cuda" else false;
      environmentVariables = {
        "OLLAMA_ORIGINS" = "app://obsidian.md*";
      };
    };
  };
}
