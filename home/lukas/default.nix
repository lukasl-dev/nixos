{ inputs, ... }:

{
  imports = [
    ./app.nix
    ./dconf.nix
    ./development.nix
    ./editors.nix
    ./gaming.nix
    ./gtk.nix
    ./hyprland.nix
    ./shell.nix
    ./terminal.nix
    ./xdg.nix

    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.05";
    username = "lukas";
    homeDirectory = "/home/lukas";
  };

  catppuccin = {
    enable = true;

    flavor = "mocha";
  };
}
