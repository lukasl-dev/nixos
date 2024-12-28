{ config, pkgs-unstable, ... }:

let
  nvidiaEnabled = config.hardware.nvidia.modesetting.enable;
in
{
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama;

    acceleration = if nvidiaEnabled then "cuda" else false;
  };
}
