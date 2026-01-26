{
  pkgs, ... }:

{
  environment.systemPackages = with pkgs.unstable; [ stylua ];
}
