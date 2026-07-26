{
  config,
  lib,
  ...
}:

let
  inherit (config) planet;
in
{
  options.planet.services.ssh = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
    };
  };

  config = {
    services.openssh = {
      enable = true;
      ports = [ planet.services.ssh.port ];

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = null;
        UseDns = false;
        PermitRootLogin = "yes";
      };
    };

    networking.firewall.allowedTCPPorts = [ planet.services.ssh.port ];
  };
}
