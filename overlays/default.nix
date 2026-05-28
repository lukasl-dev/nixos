{ inputs, lib }:

rec {
  nur = import ./nur.nix { inherit inputs; };
  unstable = import ./unstable.nix { inherit inputs; };

  default = lib.composeManyExtensions [
    nur
    unstable
  ];
}
