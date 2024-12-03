{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wayland
    wayland-protocols

    egl-wayland

    ueberzugpp
  ];
}
