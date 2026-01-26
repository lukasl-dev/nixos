{
  pkgs, ... }:

{
  environment.systemPackages = [ pkgs.unstable.devenv ];
}
