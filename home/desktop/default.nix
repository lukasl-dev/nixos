{ ... }:

{
  imports = [
    ../default.nix

    ./app
    ./desktop

    ./dconf.nix
    ./development.nix
    ./gaming.nix
    ./gtk.nix
    ./shell.nix
    ./xdg.nix
  ];
}
