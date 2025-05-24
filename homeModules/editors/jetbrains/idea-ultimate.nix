{ pkgs-unstable, ... }:

{
  imports = [ ./ideavim.nix ];

  home.packages = [
    # suffering and pain
    pkgs-unstable.jetbrains.idea-ultimate
  ];
}
