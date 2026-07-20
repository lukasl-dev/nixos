{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet.programs) herdr;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  options.planet.programs.herdr.package = lib.mkOption {
    type = lib.types.package;
    readOnly = true;
    default = inputs.herdr.packages.${system}.default;
    description = "Package used for herdr.";
  };

  config.environment.systemPackages = [ herdr.package ];
}
