{
  pkgs, ... }:

{
  environment.systemPackages = with pkgs.unstable; [ zig ];
}
