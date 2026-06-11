{ inputs, lib }:

rec {
  nur = import ./nur.nix { inherit inputs; };
  unstable = import ./unstable.nix { inherit inputs; };
  local = final: _prev: {
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
