{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet.hosting) hole;
  inherit (atlas.hosting.hole) host;

  piholeSetupScript = import (pkgs.path + "/nixos/modules/services/networking/pihole-ftl-setup-script.nix") {
    cfg = config.services.pihole-ftl;
    inherit config lib pkgs;
  };

  nonIdempotentAddList = ''
    echo "Adding list: $payload"
      type=$($jq -r '.type' <<< "$payload")
      result=$(PostFTLData "lists?type=$type" "$payload")
  '';

  idempotentAddList = ''
    local address

      type=$($jq -r '.type' <<< "$payload")
      address=$($jq -r '.address' <<< "$payload")
      result=$(GetFTLData "lists?type=$type")

      if $jq -e --arg address "$address" \
        'any(.lists[]?; .address == $address)' \
        >/dev/null <<< "$result"; then
          echo "List already present: $address"
          return
      fi

      echo "Adding list: $payload"
      result=$(PostFTLData "lists?type=$type" "$payload")
  '';

  idempotentPiholeSetupScript =
    let
      patched = lib.replaceStrings [ nonIdempotentAddList ] [ idempotentAddList ] piholeSetupScript;
    in
    assert lib.assertMsg (patched != piholeSetupScript) "Pi-hole setup script patch no longer applies";
    patched;

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

    systemd.services = {
      pihole-ftl.after = [ "systemd-resolved.service" ];

      # Nixpkgs unconditionally adds configured lists, making subsequent runs
      # fail when Pi-hole reports that the list already exists.
      pihole-ftl-setup.script = lib.mkForce idempotentPiholeSetupScript;
    };

    planet.backup.dirs = [
      "/etc/pihole"
      "/var/lib/pihole"
    ];
  };
}
