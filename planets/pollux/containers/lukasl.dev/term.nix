let
  meta = import ./meta.nix;

  sub = "term";

  sshPort = 2222;
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
          "--ssh-proxy-protocol"
        ];
      };
    }
  ];

  services.traefik.dynamicConfigOptions.tcp =
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

  networking.firewall.allowedTCPPorts = [ sshPort ];
}
