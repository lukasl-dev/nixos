{ inputs, pkgs, ... }:

{
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  programs.ags = {
    enable = true;
    # configDir = ./
    extraPackages = with pkgs; [
      gtksourceview
        webkitgtk
        accountsservice
    ];
  };
}
