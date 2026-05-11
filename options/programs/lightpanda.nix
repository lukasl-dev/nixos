{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.lightpanda.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
