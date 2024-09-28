{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wayland
    egl-wayland
  ];
}
