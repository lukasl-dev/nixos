{
  lib,
  pkgs,
  ...
}:

let
  host = "media.mizar.local";
  port = 8096;

  publishHost = pkgs.writeShellScript "publish-media-host" ''
    while true; do
      address="$(${lib.getExe' pkgs.iproute2 "ip"} -4 route get 1.1.1.1 \
        | ${lib.getExe pkgs.gawk} '
            {
              for (i = 1; i <= NF; i++) {
                if ($i == "src") {
                  print $(i + 1)
                  exit
                }
              }
            }
          ')"

      if [[ -n "$address" ]]; then
        exec ${lib.getExe' pkgs.avahi "avahi-publish"} \
          --address --no-reverse ${lib.escapeShellArg host} "$address"
      fi

      sleep 1
    done
  '';
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts.${host}.locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_buffering off;
      '';
    };
  };

  systemd.services.avahi-publish-media = {
    description = "Publish ${host} over mDNS";
    wantedBy = [ "multi-user.target" ];
    requires = [ "avahi-daemon.service" ];
    after = [
      "avahi-daemon.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      ExecStart = publishHost;
      Restart = "always";
      RestartSec = 5;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
