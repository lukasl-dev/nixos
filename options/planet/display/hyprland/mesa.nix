{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;

  inherit (pkgs.stdenv.hostPlatform) system;
  hypr-nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
in
{
  config = lib.mkIf hyprland.enable {
    hardware.graphics = {
      enable = true;
      package = hypr-nixpkgs.mesa;

      enable32Bit = true;
      package32 = hypr-nixpkgs.pkgsi686Linux.mesa;

      extraPackages = [ ];
    };

    environment.systemPackages = [ pkgs.unstable.egl-wayland ];
  };
}
