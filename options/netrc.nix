{ lib, ... }:

{
  options.planet = {
    netrc = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "netrc file";
    };
  };

  config = {
    nix.settings.netrc-file = "/etc/nix/netrc";
  };
}
