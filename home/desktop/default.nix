{ ... }:

{
  imports = [
    ../default.nix

    ./app.nix
    ./dconf.nix
    ./desktop.nix
    ./development.nix
    ./gaming.nix
    ./gtk.nix
    ./shell.nix
    ./xdg.nix
  ];
}
