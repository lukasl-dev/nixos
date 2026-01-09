{ config, inputs, ... }:

let
  meta = import ./meta.nix;

  inherit (config) sops;

  acmeDir = config.security.acme.certs.${meta.domain}.directory;
in
{
  imports = [
    ./anki.nix
    ./box.nix
    ./cloud.nix
    ./fin.nix
    ./kitchen.nix
    ./metrics.nix
    ./ntfy.nix
    ./waka.nix
    ./yam.nix
  ];

  security.acme.certs.${meta.domain} = {
    inherit (meta) domain;
    extraDomainNames = [ "*.${meta.domain}" ];
    reloadServices = [
      "traefik.service"
      "maddy.service"
    ];
  };

  services.traefik.dynamicConfigOptions = {
    tls.certificates = [
      {
        certFile = "${acmeDir}/fullchain.pem";
        keyFile = "${acmeDir}/key.pem";
      }
    ];
    http.routers = {
      dashboard = {
        rule = "Host(`proxy.${meta.domain}`)";
        entryPoints = [ "websecure" ];
        service = "api@internal";
      };
    };
  };

  containers.${meta.container} = {
    autoStart = true;

    specialArgs = { inherit inputs; };

    privateNetwork = true;
    hostAddress = meta.address.host;
    localAddress = meta.address.local;

    # Enable nesting to allow Docker to run inside the container
    # This is required for OCI containers to work.
    additionalCapabilities = [ "all" ];

    bindMounts = {
      ${acmeDir} = {
        hostPath = acmeDir;
        isReadOnly = true;
      };
      ${sops.age.keyFile} = {
        hostPath = sops.age.keyFile;
        isReadOnly = true;
      };
    };

    config = {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (config.pollux.containers.${meta.container} or [ ]);

      system.stateVersion = "25.05";

      networking = {
        hostName = meta.hostName;
        defaultGateway = meta.address.host;
        nameservers = [ "1.1.1.1" ];
      };

      virtualisation = {
        docker.enable = true;
        oci-containers.backend = "docker";
      };

      sops = {
        inherit (sops) defaultSopsFile defaultSopsFormat;
        age.keyFile = sops.age.keyFile;
      };
    };
  };
}
