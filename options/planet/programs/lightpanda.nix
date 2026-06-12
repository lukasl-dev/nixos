{
  inputs,
  pkgs,
  ...
}:
let
  lightpanda = inputs.lightpanda.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (_old: {
    # The upstream flake uses rustPlatform.fetchCargoVendor from its own
    # nixpkgs, whose helper currently downloads crates with a Python requests
    # user-agent. crates.io returns 403 for match_token-0.35.0 that way. Use
    # importCargoLock instead; it fetches the crates as individual fixed-output
    # derivations and avoids that API path.
    cargoDeps = pkgs.rustPlatform.importCargoLock {
      lockFile = "${inputs.lightpanda}/src/html5ever/Cargo.lock";
    };
  });
in
{
  environment.systemPackages = [ lightpanda ];
}
