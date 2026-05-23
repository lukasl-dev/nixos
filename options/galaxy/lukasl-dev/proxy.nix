{ config, lib, ... }:

{
  imports = [
    (lib.doRename {
      from = [ "galaxy" "lukasl-dev" "proxy" "rules" ];
      to = [ "galaxy" "proxy" "rules" "lukasl.dev" ];
      visible = true;
      warn = false;
      use = x: x;
      condition = config.galaxy.lukasl-dev.enable;
    })
  ];
}
