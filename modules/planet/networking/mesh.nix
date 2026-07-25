{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age planet;
  inherit (atlas) mesh;

  node =
    mesh.nodes.${planet.name} or (throw ''
      Planet ${planet.name} is not present in atlas.mesh.nodes.
    '');

  private = "planets/${planet.name}/mesh/private";

  publicKey =
    name:
    let
      path = ../../../secrets/planets + "/${name}/mesh/public.pub";
    in
    if builtins.pathExists path then
      lib.removeSuffix "\n" (builtins.readFile path)
    else
      throw "Missing WireGuard public key. Run `mesh-keygen ${name}`.";
in
{
  options.planet.networking.mesh.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Join the atlas WireGuard mesh.";
  };

  config = lib.mkIf planet.networking.mesh.enable {
    assertions = lib.optional (planet.name == mesh.router) {
      assertion = planet.hosting.mesh.enable;
      message = "The mesh router must enable planet.hosting.mesh.";
    };

    age.secrets.${private} = {
      rekeyFile = ../../../secrets/planets + "/${planet.name}/mesh/private.age";
      generator.script = "unixverse-wireguard";
    };

    networking = {
      firewall.trustedInterfaces = [ mesh.interface ];

      hosts = lib.mapAttrs' (
        name: value:
        lib.nameValuePair value.address (
          [ "${name}.${mesh.host}" ] ++ lib.optional (name != planet.name) name
        )
      ) mesh.nodes;

      wireguard.interfaces.${mesh.interface} = {
        ips = [ "${node.address}/32" ];
        privateKeyFile = age.secrets.${private}.path;
        dynamicEndpointRefreshSeconds = if planet.name == mesh.router then 0 else 300;

        peers =
          if planet.name == mesh.router then
            lib.mapAttrsToList (name: value: {
              publicKey = publicKey name;
              allowedIPs = [ "${value.address}/32" ];
            }) (lib.removeAttrs mesh.nodes [ planet.name ])
          else
            [
              {
                publicKey = publicKey mesh.router;
                allowedIPs = [ mesh.subnet ];
                endpoint = "${mesh.host}:${toString mesh.port}";
                persistentKeepalive = 25;
              }
            ];
      }
      // lib.optionalAttrs (planet.name == mesh.router) {
        listenPort = mesh.port;
      };
    };
  };
}
