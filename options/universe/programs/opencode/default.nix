{ inputs, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  environment.systemPackages = [ inputs.opencode.packages.${system}.default ];

  universe.hm = [
    {
      home.file.".config/opencode/config.json".source = ./config.json;
    }
  ];
}
