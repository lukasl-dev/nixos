# { pkgs, ... }:
#
# let
#   ns = pkgs.writeShellApplication {
#     name = "ns";
#     excludeShellChecks = [ "SC2016" ];
#     runtimeInputs = with pkgs; [
#       fzf
#       nix-search-tv
#     ];
#     text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
#   };
# in
{
  # universe.hm = [
  #   {
  #     programs.television = {
  #       enable = true;
  #
  #       enableBashIntegration = true;
  #       enableZshIntegration = true;
  #
  #       channels = {
  #         nix_channels = {
  #           cable_channel = [
  #             {
  #               name = "nixpkgs";
  #               source_command = "nix-search-tv print";
  #               preview_command = "nix-search-tv preview {}";
  #             }
  #           ];
  #         };
  #       };
  #     };
  #
  #     home.packages = [
  #       pkgs.unstable.nix-search-tv
  #       ns
  #     ];
  #   }
  # ];
}
