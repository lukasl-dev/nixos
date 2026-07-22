{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.hyperfine ];
}
