{ pkgs-unstable, ... }:

{
  services.ollama = {
    enable = false;
    package = pkgs-unstable.ollama;

    acceleration = "cuda";
  };
}
