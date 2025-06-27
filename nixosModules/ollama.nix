{ config, ... }:

let
  nvidiaEnabled = config.hardware.nvidia.modesetting.enable;
in
{
  services.ollama = {
    enable = true;

    acceleration = if nvidiaEnabled then "cuda" else false;
    environmentVariables = {
      "OLLAMA_ORIGINS" = "app://obsidian.md*";
    };
  };
}
