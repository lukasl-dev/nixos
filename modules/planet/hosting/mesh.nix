{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) planet;
  inherit (atlas) mesh;
in
{
  options.planet.hosting.mesh.enable = lib.mkEnableOption "WireGuard mesh router";

  config = lib.mkIf planet.hosting.mesh.enable {
    assertions = [
      {
        assertion = planet.name == mesh.router;
        message = ''
          planet.hosting.mesh can only be enabled on the atlas mesh router
          (${mesh.router}).
        '';
      }
    ]
    ++ lib.mapAttrsToList (name: proxy: {
      assertion = builtins.hasAttr proxy.node mesh.nodes;
      message = ''
        Mesh proxy ${name} references unknown node ${proxy.node}.
      '';
    }) mesh.proxies;

    planet = {
      networking.mesh.enable = true;
      hosting.proxy = {
        enable = true;
        rules = lib.mapAttrs (
          _: proxy:
          let
            node = mesh.nodes.${proxy.node} or { address = "127.0.0.1"; };
          in
          {
            ingress = {
              inherit (proxy) host;
              http.path = {
                exact = proxy.exact or null;
                prefix = proxy.prefix or null;
              };
            };

            upstream.http.url = "${proxy.scheme or "http"}://${node.address}:${toString proxy.port}";
          }
        ) mesh.proxies;
      };
    };

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    networking.firewall.allowedUDPPorts = [ mesh.port ];
  };
}
