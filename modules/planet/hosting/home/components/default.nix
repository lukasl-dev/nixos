{
  pythonPackages,
  lib,
  pkgs,
}:

[
  (import ./gree.nix {
    inherit pythonPackages lib pkgs;
  })
  (import ./tplink-deco.nix {
    inherit pythonPackages lib pkgs;
  })
  (import ./easy-stock.nix {
    inherit pythonPackages lib pkgs;
  })
]
