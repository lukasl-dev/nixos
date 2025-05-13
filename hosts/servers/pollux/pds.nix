{
  meta,
  inputs,
  ...
}:

let
  port = 2997;
in
{
  # TODO: remove when pds becomes stable
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/pds.nix"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      pdsadmin = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.pdsadmin;
      pds = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.pds;
    })
  ];

  services.pds = {
    enable = true;
    settings = {
      PDS_HOSTNAME = "pds.${meta.domain}";
      PDS_PORT = port;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.pds = {
      rule = "Host(`pds.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "pds";
    };
    services.pds = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString port}";
        }
      ];
    };
  };
}
