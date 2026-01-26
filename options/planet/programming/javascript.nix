{
  pkgs, lib, ... }:

{
  options.planet.development.javascript = {
    enable = lib.mkEnableOption "Enable javascript";
  };

  config = {
    environment.systemPackages = with pkgs.unstable; [ nodejs ];

    universe.hm = [
      {
        programs.bun = {
          enable = true;
          package = pkgs.unstable.bun;
        };
      }
    ];
  };
}
