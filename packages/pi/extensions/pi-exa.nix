{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "joemccann";
  repo = "pi-exa";
  rev = "efbfd05100547ed435f94d4bba1e77919cf9e681";
  hash = "sha256-egzx2BXEbyiOr0F7iuPa8f3QXjkCOvWl4V3GTsA1vyk=";
}
