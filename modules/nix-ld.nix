{ pkgs, lib, ... }:

let
  libraries = with pkgs; [
    libGL
    libglvnd
    stdenv.cc.cc
    stdenv.cc
    wayland
    zlib
    glib
    glfw-wayland
    glfw-wayland-minecraft
  ];
in
{
  programs.nix-ld = {
    enable = true;
    libraries = libraries;
  };

  environment.sessionVariables.LD_LIBRARY_PATH = [
    "/run/current-system/sw/share/nix-ld/lib"
    # "${pkgs.stdenv.cc.cc.lib}/lib"
    "${lib.makeLibraryPath libraries}"
  ];
}
