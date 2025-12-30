let
  domain = import ./domain.nix;
in
{
  security.acme.certs.${domain} = {
    inherit domain;
    extraDomainNames = [ "*.${domain}" ];
    reloadServices = [ "traefik.service" ];
  };

  containers.${domain} = {
    autoStart = true;

    config =
      { pkgs, ... }:
      {
        networking.hostName = builtins.replaceStrings [ "." ] [ "-" ] domain;
      };
  };
}
