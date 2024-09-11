{ pkgs, ... }:

{
  home.packages = with pkgs; [
    prismlauncher
    glfw-wayland-minecraft
  ];
}
