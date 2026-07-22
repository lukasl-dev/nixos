{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.perf ];
}
