{ pkgs, ... }:

{
  imports = [
    ../../desktop/nixos

    ../../../nixosModules/system/thermald.nix
    ../../../nixosModules/system/tlp.nix
  ];

  environment.systemPackages =  [
    pkgs.brightnessctl
  ];
}
