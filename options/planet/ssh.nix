{
  config,
  lib,
  ...
}:

let
  inherit (config.planet) ssh user;
in
{
  options.planet = {
    ssh = {
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

          matchBlocks = {
            "*" = {
              identityFile = ssh.default.privateKey;
            };

            "g0.complang.tuwien.ac.at" = {
              identityFile = ssh."g0.complang.tuwien.ac.at".privateKey;
              identitiesOnly = true;
            };
          };
        };

        home.file.".ssh/id_ed25519.pub".text = ssh.default.publicKey;
      }
    ];

    networking.firewall.allowedTCPPorts = [ 22 ];

    users.users = {
      root.openssh.authorizedKeys.keys = [ ssh.default.publicKey ];
      ${user.name}.openssh.authorizedKeys.keys = [ ssh.default.publicKey ];
    };
  };
}
