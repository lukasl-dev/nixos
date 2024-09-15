{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ egl-wayland ];
}
