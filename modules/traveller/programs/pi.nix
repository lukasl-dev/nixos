{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) traveller;

  opencodeApiKey = atlas.secrets.universe [
    "pi"
    "opencode"
    "apiKey"
  ];
  exaApiKey = atlas.secrets.universe [
    "pi"
    "exa"
    "apiKey"
  ];
in
{
  options.traveller.programs.pi.enable = lib.mkEnableOption "the Pi coding agent";

  config.traveller.modules = lib.optionals traveller.programs.pi.enable [
    (
      {
        config,
        inputs,
        pkgs,
        ...
      }:

      let
        inherit (config) age;
        inherit (pkgs.stdenv.hostPlatform) system;

        pi = inputs.pi.lib.mkCodingAgent {
          inherit pkgs;
          modules = [
            {
              pi.coding-agent = {
                package = inputs.self.packages.${system}.pi;
                environment = {
                  OPENCODE_API_KEY.file = age.secrets.${opencodeApiKey}.path;
                  EXA_API_KEY.file = age.secrets.${exaApiKey}.path;
                };
              };
            }
          ];
        };
      in
      {
        age.secrets = {
          ${opencodeApiKey} = {
            rekeyFile = ../../../secrets + "/${opencodeApiKey}.age";
            owner = traveller.user.name;
            mode = "0400";
          };

          ${exaApiKey} = {
            rekeyFile = ../../../secrets + "/${exaApiKey}.age";
            owner = traveller.user.name;
            mode = "0400";
          };
        };

        users.users.${traveller.user.name}.packages = [ pi.package ];
      }
    )
  ];
}
