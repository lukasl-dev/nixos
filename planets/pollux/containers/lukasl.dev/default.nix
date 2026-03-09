{ config, inputs, ... }:

let
  meta = import ./meta.nix;

  inherit (config) sops;
  inherit (config.universe) user;
  inherit (config.planet) name;
  agenixIdentity = "/home/${user.name}/.ssh/id_ed25519";

  acmeDir = config.security.acme.certs.${meta.domain}.directory;
in
{
  imports = [
    ./anki.nix
    ./box.nix
    ./cloud.nix
    ./fin.nix
    # ./forge.nix
    ./factorio.nix
    ./kitchen.nix
    ./marks.nix
    ./metrics.nix
    ./ntfy.nix
    ./pdf.nix
    ./term.nix
    ./todo.nix
    ./waka.nix
    ./yam.nix
  ];

  security.acme.certs.${meta.domain} = {
    inherit (meta) domain;
    extraDomainNames = [ "*.${meta.domain}" ];
    reloadServices = [
      "traefik.service"
      "maddy.service"
      "container@lukasl.dev.service"
    ];
  };

  services.resolved.extraConfig = "DNSStubListenerExtra=${meta.address.host}";

  networking.firewall.interfaces."ve-${meta.container}" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
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
      ${agenixIdentity} = {
        hostPath = agenixIdentity;
        isReadOnly = true;
      };
    };

    config = {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (config.pollux.containers.${meta.container} or [ ]);

      nixpkgs = {
        inherit (config.nixpkgs) overlays config;
      };

      system.stateVersion = "25.05";

      networking = {
        inherit (meta) hostName;
        defaultGateway = meta.address.host;
        useHostResolvConf = false;
        nameservers = [ meta.address.host ];
      };

      virtualisation = {
        docker.enable = true;
        oci-containers.backend = "docker";
      };

      sops = {
        inherit (sops) defaultSopsFile defaultSopsFormat;
        age.keyFile = sops.age.keyFile;
      };

      age = {
        identityPaths = [ agenixIdentity ];

        rekey = {
          masterIdentities = [ agenixIdentity ];
          hostPubkey = builtins.readFile ../../../../options/universe/ssh/id_ed25519.pub;
          storageMode = "local";
          localStorageDir = "${toString ../../../../secrets/_}/${name}";
        };
      };
    };
  };
}
