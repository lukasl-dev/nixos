let
  domain = import ./domain.nix;
in
{
  # security.acme.certs.${domain} = {
  #   inherit domain;
  #   extraDomainNames = [ "*.${domain}" ];
  #   reloadServices = [
  #     "traefik.service"
  #     "maddy.service"
  #   ];
  # };

  containers.${domain} = {
    autoStart = true;

    config = { pkgs, ... }: { };
  };
}
