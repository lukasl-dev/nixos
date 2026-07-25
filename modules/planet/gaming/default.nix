{
  config,
  lib,
  pkgs,
  ...
}:

let
  dxvk = pkgs.symlinkJoin {
    name = "dxvk-${pkgs.dxvk.version}";
    paths = [ pkgs.dxvk.out ];
  };
in
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

  config.environment.systemPackages = lib.mkIf config.planet.gaming.enable [
    dxvk
  ];
}
