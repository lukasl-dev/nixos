{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libGL
      libglvnd
    ];
  };

  environment.sessionVariables.LD_LIBRARY_PATH = [ "/run/current-system/sw/share/nix-ld/lib" ];
}
