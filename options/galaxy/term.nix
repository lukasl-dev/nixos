{ lib, ... }:

{
  options.galaxy.term = {
    enable = lib.mkEnableOption "Enable uptermd";

    port = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      readOnly = true;
      description = "Port for the uptermd server.";
    };
  };
}
