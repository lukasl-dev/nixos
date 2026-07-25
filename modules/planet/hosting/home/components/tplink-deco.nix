{
  hassPythonPackages,
  lib,
  pkgs,
}:

pkgs.unstable.buildHomeAssistantComponent rec {
  owner = "amosyuen";
  domain = "tplink_deco";
  version = "3.9.2";

  src = pkgs.unstable.fetchFromGitHub {
    inherit owner;
    repo = "ha-tplink-deco";
    rev = "59f5b361cf00df2721a499d37751613423d3d8d3";
    hash = "sha256-AeEWKGIRwiro6J0ShrlJ4MnVl0Oxmi5KYav0RWLh6xo=";
  };

  dependencies = with hassPythonPackages; [
    pycryptodome
  ];

  meta = {
    changelog = "https://github.com/amosyuen/ha-tplink-deco/releases/tag/v${version}";
    description = "TP-Link Deco custom integration for Home Assistant";
    homepage = "https://github.com/amosyuen/ha-tplink-deco";
    license = lib.licenses.mit;
  };
}
