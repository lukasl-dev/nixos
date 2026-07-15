{ config, lib, ... }:

let
  inherit (config.galaxy) todo;

  listenAddress = "127.0.0.1";
in
{
  imports = [ ./sync.nix ];

  options.galaxy.todo = {
    enable = lib.mkEnableOption "Enable Super Productivity";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      readOnly = true;
      description = "Port for the Super Productivity web app.";
    };
  };

  config = lib.mkIf todo.enable {
    virtualisation.oci-containers.containers.super-productivity = {
      image = "johannesjo/super-productivity:latest";
      ports = [ "${listenAddress}:${toString todo.port}:80" ];
    };

    galaxy.proxy.rules = [
      {
        name = "todo";
        to.http = "http://${listenAddress}:${toString todo.port}";
      }
    ];
  };
}
