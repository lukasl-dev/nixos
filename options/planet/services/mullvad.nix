{
  pkgs,
  config,
  lib,
  ...
}:

let
  inherit (config.planet) wm;

  inherit (config.planet.services) mullvad;
in
{
  options.planet.services.mullvad = {
    enable = lib.mkEnableOption "Enable mullvad vpn";

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = pkgs.unstable.mullvad-vpn;
      description = "Package used for Mullvad VPN.";
      example = "pkgs.unstable.mullvad-vpn";
    };

    launch = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = lib.getExe mullvad.package;
      description = "Command used to launch Mullvad VPN.";
      example = "mullvad-vpn";
    };
  };

  config = lib.mkIf mullvad.enable {
    planet.wm.hyprland.launch = [ mullvad.launch ];

    services.mullvad-vpn = {
      enable = true;
      package = lib.mkIf wm.enable mullvad.package;
    };

    environment.systemPackages = [
      mullvad.package
      (lib.mkIf wm.enable pkgs.unstable.mullvad-browser)
    ];

    # Tailscale + Mullvad compatibility
    # See: https://theorangeone.net/posts/tailscale-mullvad/
    #
    # Two-part solution:
    # 1. nftables rules mark Tailscale IP traffic (100.64.0.0/10) to bypass Mullvad
    # 2. Split-tunnel excludes tailscaled process for control plane traffic
    #
    # IMPORTANT: Mullvad's content-blocking DNS uses 100.64.0.0/24, which overlaps
    # with Tailscale's CGNAT range. We must exclude that range from the bypass.
    networking.nftables.tables.mullvad-tailscale = lib.mkIf config.services.tailscale.enable {
      family = "inet";
      content = ''
        chain output {
          type route hook output priority -100; policy accept;
          # Skip Mullvad's DNS range (100.64.0.0/24) - let it go through the tunnel
          ip daddr 100.64.0.0/24 return;
          # Mark Tailscale traffic to bypass Mullvad
          ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
        }

        chain input {
          type filter hook input priority -100; policy accept;
          # Skip Mullvad's DNS range
          ip saddr 100.64.0.0/24 return;
          # Mark Tailscale traffic to bypass Mullvad
          ip saddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
        }
      '';
    };

    systemd.services.tailscaled.serviceConfig.ExecStartPost =
      lib.mkIf config.services.tailscale.enable
        [
          "-${mullvad.package}/bin/mullvad split-tunnel add $MAINPID"
        ];

    # ensure mullvad uses default dns (not content-blocking dns)
    # content-blocking dns uses 100.64.0.x which conflicts with tailscale's cgnat range
    systemd.services.mullvad-dns-fix = lib.mkIf config.services.tailscale.enable {
      description = "Configure Mullvad DNS for Tailscale compatibility";
      wantedBy = [ "multi-user.target" ];
      after = [ "mullvad-daemon.service" ];
      requires = [ "mullvad-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${mullvad.package}/bin/mullvad dns set default";
        RemainAfterExit = true;
      };
    };
  };
}
