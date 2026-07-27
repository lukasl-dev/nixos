{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "tmustier";
  repo = "pi-extensions";
  rev = "a6839e57c0f0d8d534b01e646abce2d6530faf01";
  hash = "sha256-ecS05kVnga1y+OoRoUH7/+WCrQsxgP/q/AcSWAPyO8o=";
}
