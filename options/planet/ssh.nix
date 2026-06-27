{
  config,
  lib,
  ...
}:

let
  inherit (config.planet) ssh user;
  inherit (config.galaxy.lukasl-dev) forge;
in
{
  options.planet = {
    ssh = {
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ 2222 ];
        description = "Ports for the host OpenSSH server.";
      };

      pollux = {
        host = lib.mkOption {
          type = lib.types.str;
          default = "pollux.lukasl.dev";
          readOnly = true;
          description = "Public hostname for Pollux administrative SSH.";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 2222;
          readOnly = true;
          description = "Port for pollux SSH.";
        };
      };

      ida = {
        port = lib.mkOption {
          type = lib.types.port;
          default = 2222;
          readOnly = true;
          description = "Port for ida SSH.";
        };
      };

      default = {
        publicKey = lib.mkOption {
          type = lib.types.str;
          description = "Public SSH key content.";
        };

        privateKey = lib.mkOption {
          type = lib.types.path;
          description = "Private SSH key file path. Path values are copied to the Nix store.";
          example = lib.literalExpression "./id_ed25519";
        };
      };

      "g0.complang.tuwien.ac.at" = {
        privateKey = lib.mkOption {
          default = lib.types.path;
          description = "Private SSH key file path. Path values are copied to the Nix store.";
          example = lib.literalExpression "./id_ed25519";
        };
      };
    };
  };

  config = {
    services.openssh = {
      enable = true;
      inherit (ssh) ports;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = null;
        UseDns = true;
        PermitRootLogin = "yes";
      };
    };

    planet.hm = [
      {
        programs.ssh = {
          enable = true;

          enableDefaultConfig = false;

          settings = {
            "*" = {
              IdentityFile = ssh.default.privateKey;
            };

            "g0.complang.tuwien.ac.at" = {
              IdentityFile = ssh."g0.complang.tuwien.ac.at".privateKey;
              IdentitiesOnly = true;
            };

            "pollux" = {
              HostName = ssh.pollux.host;
              Port = ssh.pollux.port;
            };
            ${ssh.pollux.host} = {
              Port = ssh.pollux.port;
            };

            "ida" = {
              Port = ssh.ida.port;
            };
            "ida.local" = {
              Port = ssh.ida.port;
            };

            ${forge.host} = {
              User = "forgejo";
              Port = forge.sshPort;
            };
          };
        };

        home.file.".ssh/id_ed25519.pub".text = ssh.default.publicKey;
      }
    ];

    networking.firewall.allowedTCPPorts = ssh.ports;

    users.users = {
      root.openssh.authorizedKeys.keys = [ ssh.default.publicKey ];
      ${user.name}.openssh.authorizedKeys.keys = [ ssh.default.publicKey ];
    };
  };
}
