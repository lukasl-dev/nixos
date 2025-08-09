{ pkgs-unstable, lib, ... }:

{
  options.planet.development.go = {
    enable = lib.mkEnableOption "Enable go";
  };

  config = {
    environment.systemPackages = with pkgs-unstable; [
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
          package = pkgs-unstable.go_1_24;
        };
      }
    ];
  };
}
