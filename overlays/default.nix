{ inputs, lib }:

rec {
  nur = import ./nur.nix { inherit inputs; };
  unstable = import ./unstable.nix { inherit inputs; };
  local = final: _prev: {
    netbird-proxy = final.callPackage ../packages/netbird-proxy {
      buildGoModule = final.unstable.buildGoModule;
    };
    netbird-server = final.callPackage ../packages/netbird-server {
      buildGoModule = final.unstable.buildGoModule;
    };
  };

  default = lib.composeManyExtensions [
    nur
    unstable
    local
  ];
}
