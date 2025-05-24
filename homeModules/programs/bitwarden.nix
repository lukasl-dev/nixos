{ pkgs-unstable, ... }:

{
  home.packages = [
    pkgs-unstable.bitwarden
    pkgs-unstable.bitwarden-cli
  ];
}
