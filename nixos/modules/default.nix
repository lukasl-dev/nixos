{
  flake.nixosModules = {
    polkit-gnome = import ./services/polkit-gnome.nix;
  };
}
