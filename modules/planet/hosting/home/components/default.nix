{
  hassPythonPackages,
  lib,
  pkgs,
}:

[
  (import ./gree.nix {
    inherit hassPythonPackages lib pkgs;
  })
  (import ./tplink-deco.nix {
    inherit hassPythonPackages lib pkgs;
  })
]
