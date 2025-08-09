{ pkgs-unstable, ... }:

{
  environment.systemPackages = [ pkgs-unstable.devenv ];
}
