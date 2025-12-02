{ self, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  environment = {
    systemPackages = [ self.packages.${system}.vim ];

    sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
