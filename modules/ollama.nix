{ pkgs-unstable, ... }:

{
  services.ollama = {
    enable = false;
    package = pkgs-unstable.ollama;

    acceleration = "cuda"; # TODO: only enable if nvidia is enabled
  };
}
