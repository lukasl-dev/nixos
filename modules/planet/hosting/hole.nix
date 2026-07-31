{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.hosting) hole;
  inherit (atlas.hosting.hole) host;

  dnsPort = 53;
  webPort = 2718;
in
{
  options.planet.hosting.hole.enable = lib.mkEnableOption "Pi-hole";

  config = lib.mkIf hole.enable {
    services = {
      pihole-ftl = {
        enable = true;
        privacyLevel = 1;
        openFirewallDNS = false;

        settings.dns = {
          listeningMode = "LOCAL";
          upstreams = [
            "1.1.1.1"
            "1.0.0.1"
            "8.8.8.8"
            "8.8.4.4"
          ];
        };

        lists = [
          {
            url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
            type = "block";
            enabled = true;
            description = "Hagezi blocklist";
          }
        ];
      };

      pihole-web = {
        enable = true;
        hostName = host;
        ports = [ webPort ];
      };

      resolved.settings.Resolve = {
        DNSStubListener = false;
        DNSStubListenerExtra = lib.mkForce [ ];
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ dnsPort ];
      allowedUDPPorts = [ dnsPort ];
    };

    systemd.services.pihole-ftl.after = [ "systemd-resolved.service" ];

    planet.backup.dirs = [
      "/etc/pihole"
      "/var/lib/pihole"
    ];
  };
}
