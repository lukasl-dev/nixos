{
  config,
  lib,
  ...
}:

let
  inherit (config) planet;
in
{
  options.planet.ssh = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
    };
  };

  config = {
    services.openssh = {
      enable = true;
      inherit (planet.ssh) ports;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = null;
        UseDns = false;
        PermitRootLogin = "yes";
      };
    };

    networking.firewall.allowedTCPPorts = [ planet.ssh.port ];
  };
}
