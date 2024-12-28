{ ... }:

{
  imports = [
    ../default.nix

    ./desktop

    ./app.nix
    ./dconf.nix
    ./development.nix
    ./gaming.nix
    ./gtk.nix
    ./shell.nix
    ./xdg.nix
  ];
}
