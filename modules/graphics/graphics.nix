{ pkgs, inputs, ... }:

let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  hardware.graphics = {
    package = pkgs-unstable.mesa;

    enable32Bit = true;
    package32 = pkgs-unstable.pkgsi686Linux.mesa;

    extraPackages = with pkgs-unstable; [
      rocmPackages.clr
    ];
  };
}
