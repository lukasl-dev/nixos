{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet.dev) go;
in
{
  options.planet.dev.go = {
    enable = lib.mkEnableOption "Enable go";
  };

  config = lib.mkIf go.enable {
    environment.systemPackages = with pkgs.unstable; [
      delve
      gopls
      nilaway
      golangci-lint
      golangci-lint-langserver
    ];

    universe.hm = [
      {
        programs.go = {
          enable = true;
          package = pkgs.unstable.go_1_24;
        };
      }
    ];
  };
}
