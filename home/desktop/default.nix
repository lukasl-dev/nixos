{ inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin

    ./app.nix
    ./dconf.nix
    ./desktop.nix
    ./development.nix
    ./editor.nix
    ./gaming.nix
    ./gtk.nix
    ./xdg.nix
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
}
