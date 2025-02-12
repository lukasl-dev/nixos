{ config, ... }:

let
  nvidiaEnabled = config.hardware.nvidia.modesetting.enable;
in
{
  services.ollama = {
    enable = true;

    acceleration = if nvidiaEnabled then "cuda" else false;
  };
}
