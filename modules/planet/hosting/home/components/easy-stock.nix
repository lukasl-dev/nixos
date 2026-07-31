{
  pythonPackages,
  lib,
  pkgs,
}:

pkgs.unstable.buildHomeAssistantComponent rec {
  owner = "derspe";
  domain = "easy_stock";
  version = "0.3.2";

  src = pkgs.unstable.fetchFromGitHub {
    inherit owner;
    repo = "ha-easy-stock";
    rev = "e2565a81e872aa9ed0dc593d0c5e473573828927";
    hash = "sha256-Pqva1L6c4GapvLXNnhjBTkJlPsNjv/F/DdQLQvMmd0I=";
  };

  dependencies = with pythonPackages [ ];

  meta = {
    description = "Easy Stock — Yahoo Finance stock/ETF/crypto tracker with sparkline Lovelace card";
    homepage = "https://github.com/derspe/ha-easy-stock";
    license = lib.licenses.mit;
  };
}
