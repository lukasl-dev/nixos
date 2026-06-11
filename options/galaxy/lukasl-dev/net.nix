{ config, lib, ... }:

let
  inherit (config.galaxy.lukasl-dev)
    domain
    addresses
    net
    ;

  isGuest = net.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/netbird";

  backendRule = name: pathPrefix: {
    type = "https";
    inherit name;
    priority = 100;
    from = {
      host = net.host;
      inherit pathPrefix;
    };
    to.http = "http://${listenAddress}:${toString net.port}";
  };

  grpcRule = name: pathPrefix: {
    type = "https";
    inherit name;
    priority = 100;
    from = {
      host = net.host;
      inherit pathPrefix;
    };
    to.http = "h2c://${listenAddress}:${toString net.port}";
  };

  module = {
    services.netbird.server = {
      enable = true;
      domain = net.host;
      listenAddress = listenAddress;
      port = net.port;
      dashboardListenAddress = listenAddress;
      dashboardPort = net.dashboardPort;
      stunPort = net.stunPort;
      openFirewall = net.openFirewall;
      reverseProxy =
        lib.optionalAttrs isGuest {
          trustedHTTPProxies = [ "${addresses.host}/32" ];
        }
        // lib.optionalAttrs (!isGuest) {
          trustedHTTPProxiesCount = 1;
        };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf isGuest [
      net.port
      net.dashboardPort
    ];
  };
in
{
  options.galaxy.lukasl-dev.net = {
    enable = lib.mkEnableOption "Enable NetBird";

    mode = lib.mkOption {
      type = lib.types.enum [
        "guest"
        "host"
      ];
      default = config.galaxy.lukasl-dev.mode;
      description = "Whether to run NetBird in the lukasl-dev container or on the host.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "netbird.${domain}";
      description = "Public hostname for NetBird.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Local HTTP/gRPC/WebSocket listen port for netbird-server.";
    };

    dashboardPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Local dashboard listen port.";
    };

    stunPort = lib.mkOption {
      type = lib.types.port;
      default = 3478;
      description = "UDP STUN port served directly by netbird-server.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open public TCP 80/443 through the shared proxy and UDP stunPort for NetBird.";
    };
  };

  config = lib.mkIf net.enable (
    lib.mkMerge [
      {
        galaxy.lukasl-dev = {
          backup.paths = [
            (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
          ];

          proxy.rules = [
            (grpcRule "netbird-grpc-signal" "/signalexchange.SignalExchange/")
            (grpcRule "netbird-grpc-management" "/management.ManagementService/")
            (grpcRule "netbird-grpc-proxy" "/management.ProxyService/")
            (backendRule "netbird-backend-relay" "/relay")
            (backendRule "netbird-backend-ws" "/ws-proxy/")
            (backendRule "netbird-backend-api" "/api")
            (backendRule "netbird-backend-oauth2" "/oauth2")
            {
              type = "https";
              name = "netbird-dashboard";
              priority = 1;
              from.host = net.host;
              to.http = "http://${listenAddress}:${toString net.dashboardPort}";
            }
          ];

          modules.net = {
            inherit (net) mode;
            inherit module;
          };
        };

        networking.firewall.allowedTCPPorts = lib.mkIf net.openFirewall [
          80
          443
        ];
      }

      (lib.mkIf (isGuest && net.openFirewall) {
        containers.lukasl-dev.forwardPorts = [
          {
            protocol = "udp";
            hostPort = net.stunPort;
            containerPort = net.stunPort;
          }
        ];
      })

      (lib.mkIf (!isGuest) module)
    ]
  );
}
