{
  inputs,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  environment = {
    systemPackages = [ inputs.self.packages.${system}.vim ];
    sessionVariables.EDITOR = "nvim";
  };
}
