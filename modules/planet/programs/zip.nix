{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.unzip
    pkgs.zip
  ];
}
