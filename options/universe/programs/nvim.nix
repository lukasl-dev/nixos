{ self, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = [
    self.packages.${system}.vim
  ];
}
