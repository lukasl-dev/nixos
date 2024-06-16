{ inputs, pkgs, ... }:

{
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  programs.ags = {
    enable = true;
    configDir = ../../dots/ags;
    extraPackages = with pkgs; [
      gtksourceview
        webkitgtk
        accountsservice
    ];
  };
}
