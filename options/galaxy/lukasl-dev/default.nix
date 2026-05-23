{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) stateVersion;
  inherit (config.galaxy) lukasl-dev;
in
{
  imports = [
    ./acme.nix
    ./proxy.nix

    ./matrix

    ./anki.nix
    ./books.nix
    ./box.nix
    ./cal.nix
    ./factorio.nix
    ./forge.nix
    ./notes.nix
    ./term.nix
    ./waka.nix
    ./www.nix
  ];

  options.galaxy = {
    lukasl-dev = {
      enable = lib.mkEnableOption "Join the lukasl-dev galaxy";

      domain = lib.mkOption {
        type = lib.types.str;
        default = "lukasl.dev";
        readOnly = true;
      };

      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [ ];
        description = "A list of NixOS modules to be imported within the container.";
      };

      bindMounts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = age.identityPaths ++ age.masterIdentities;
        description = "Host paths to bind mount read-only into the lukasl-dev container.";
      };

      addresses = lib.mkOption {
        type = lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
            };

            local = lib.mkOption {
              type = lib.types.str;
              readOnly = true;
            };
          };
        };
        default = {
          host = "10.100.0.1";
          local = "10.100.0.2";
        };
        readOnly = true;
        description = "Network addresses for the lukasl-dev container.";
      };
    };
  };

  config = lib.mkIf lukasl-dev.enable {
    galaxy.proxy.enable = true;

    # DNS
    services.resolved.extraConfig = "DNSStubListenerExtra=${lukasl-dev.addresses.host}";
    networking.firewall.interfaces."ve-lukasl-dev" = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };

    containers.lukasl-dev = {
      autoStart = true;
      specialArgs = { inherit inputs; };

      privateNetwork = true;
      hostAddress = lukasl-dev.addresses.host;
      localAddress = lukasl-dev.addresses.local;

      # enable nesting to allow docker to run inside the container
      additionalCapabilities = [ "all" ];

      bindMounts =
        let
          bindMount = path: {
            name = path;
            value = {
              hostPath = path;
              isReadOnly = true;
            };
          };
        in
        lib.listToAttrs (map bindMount lukasl-dev.bindMounts);

      config = {
        imports = lukasl-dev.modules;

        system.stateVersion = stateVersion;

        networking = {
          hostName = "lukasl-dev";
          defaultGateway = lukasl-dev.addresses.host;
          useHostResolvConf = false;
          nameservers = [ lukasl-dev.addresses.host ];
        };

        virtualisation = {
          docker.enable = true;
          oci-containers.backend = "docker";
        };
      };
    };
  };
}
