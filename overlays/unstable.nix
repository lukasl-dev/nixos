{ inputs }:

final: _prev: {
  unstable = import inputs.nixpkgs-unstable {
    inherit (final.stdenv.hostPlatform) system;
    config = final.config;
  };
}
