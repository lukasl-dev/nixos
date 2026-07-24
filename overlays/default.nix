{ inputs, lib }:

rec {
  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      inherit (final) config;
    };
  };
  nur = inputs.nur.overlays.default;

  default = lib.composeManyExtensions [
    nur
    unstable
  ];
}
