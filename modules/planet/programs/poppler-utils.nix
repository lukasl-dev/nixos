{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.poppler-utils ];
}
