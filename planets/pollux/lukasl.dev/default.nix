{ config, ... }:

let
  domain = import ./domain.nix;

  # inherit (config) sops;

  acmeDir = config.security.acme.certs.${domain}.directory;
in
{
  security.acme.certs.${domain} = {
    inherit domain;
    extraDomainNames = [ "*.${domain}" ];
    reloadServices = [
      "traefik.service"
      "maddy.service"
    ];
  };

  containers.${domain} = {
    autoStart = true;

    bindMounts = {
      ${acmeDir} = {
        hostPath = acmeDir;
        isReadOnly = true;
      };
    };

    config = {
      imports = [
        # inputs.sops-nix.nixosModules.sops
      ];

      system.stateVersion = "25.05";

      networking.hostName = builtins.replaceStrings [ "." ] [ "-" ] domain;
    };
  };
}
