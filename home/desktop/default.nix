{ inputs, ... }:

{
  imports = [
    ../default.nix

    ./app.nix
    ./dconf.nix
    ./desktop.nix
    ./development.nix
    ./editor.nix
    ./gaming.nix
    ./gtk.nix
    ./shell.nix
    ./xdg.nix

    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
}
