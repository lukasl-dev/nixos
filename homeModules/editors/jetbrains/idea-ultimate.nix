{ pkgs-unstable, ... }:

{
  imports = [ ./ideavim.nix ];

  # suffering and pain
  home.packages = [ pkgs-unstable.jetbrains.idea-ultimate ];
}
