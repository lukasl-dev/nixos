{
  hassPythonPackages,
  lib,
  pkgs,
}:

pkgs.unstable.buildHomeAssistantComponent rec {
  owner = "RobHofmann";
  domain = "gree";
  version = "3.6.0";

  src = pkgs.unstable.fetchFromGitHub {
    inherit owner;
    repo = "HomeAssistant-GreeClimateComponent";
    rev = version;
    hash = "sha256-L46+PRg7kxByMJ5vjNHgEx2QQSFib9H0UMW1eVayCQM=";
  };

  dependencies = with hassPythonPackages; [
    aiofiles
    pycryptodome
  ];

  meta = {
    description = "Custom Gree climate component for Home Assistant";
    homepage = "https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
    license = lib.licenses.gpl3Only;
  };
}
