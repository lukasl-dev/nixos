let
  meta = import ./meta.nix;

  sub = "term";
  hostName = "${sub}.${meta.domain}";

  sshPort = 2222;
  wsPort = 8443;
in
{
  pollux.containers.${meta.container} = [
    {
      services.uptermd = {
        enable = true;
        port = sshPort;
        listenAddress = meta.address.local;
        openFirewall = true;
        extraFlags = [
          "--ssh-addr=${meta.address.local}:${toString sshPort}"
          "--ws-addr=${meta.address.local}:${toString wsPort}"
          "--ssh-proxy-protocol"
        ];
      };
    }
  ];

  services.traefik.dynamicConfigOptions = {
    tcp =
      let
        name = meta.router sub;
      in
      {
        services.${name} = {
          loadBalancer = {
            servers = [
              {
                address = "${meta.address.local}:${toString sshPort}";
              }
            ];
            proxyProtocol.version = 2;
          };
        };
        routers.${name} = {
          rule = "HostSNI(`*`)";
          entryPoints = [ "uptermd" ];
          service = name;
        };
      };
    http =
      let
        wsName = "${sub}-ws-${meta.hostName}";
      in
      {
        services.${wsName} = {
          loadBalancer.servers = [
            {
              url = "http://${meta.address.local}:${toString wsPort}";
            }
          ];
        };
        routers.${wsName} = {
          rule = "Host(`${hostName}`)";
          entryPoints = [ "websecure" ];
          service = wsName;
          tls = { };
        };
      };
  };

  networking.firewall.allowedTCPPorts = [ 2222 ];
}
