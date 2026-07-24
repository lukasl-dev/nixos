{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (pkgs.stdenv.hostPlatform) system;

  hyprlandPkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
in
{
  config = lib.mkIf planet.desktop.enable {
    hardware.graphics = {
      enable = true;
      package = hyprlandPkgs.mesa;
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
      enable32Bit = true;
      package32 = hyprlandPkgs.pkgsi686Linux.mesa;
    };

    environment.systemPackages = [ hyprlandPkgs.egl-wayland ];
  };
}
