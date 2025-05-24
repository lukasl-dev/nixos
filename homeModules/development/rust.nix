{ pkgs-unstable, ... }:

{
  imports = [ ./cargo ];

  home.packages = [
    pkgs-unstable.rustc
    pkgs-unstable.clippy
    pkgs-unstable.rustfmt
  ];
}
