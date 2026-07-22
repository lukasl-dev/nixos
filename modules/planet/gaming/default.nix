{ lib, ... }:

{
  imports = [
    ./gamemode.nix
    ./gamescope.nix
    ./minecraft.nix
    ./proton.nix
    ./r2modman.nix
    ./steam.nix
    ./wine.nix
  ];

  options.planet.gaming.enable = lib.mkEnableOption "gaming support";
}
