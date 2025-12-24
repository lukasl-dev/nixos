{ config, lib, ... }:

let
  inherit (config.universe) jujutsu;
in
{
  options.universe.jujutsu = {
    user = lib.mkOption {
      type = lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            description = "Email address used for jj commits.";
            default = "";
            example = "git@lukasl.dev";
          };

          name = lib.mkOption {
            type = lib.types.str;
            description = "Username used for jj commits.";
            default = "";
            example = "lukasl-dev";
          };
        };
      };
      default = { };
    };
  };

  config = {
    assertions = [
      {
        assertion = jujutsu.user.email != "";
        message = "🪐 Please define 'universe.jujutsu.user.email'.";
      }
      {
        assertion = jujutsu.user.name != "";
        message = "🪐 Please define 'universe.jujutsu.user.name'.";
      }
    ];

    universe.hm = [
      {
        programs.jujutsu = {
          enable = true;

          settings = {
            user = { inherit (jujutsu.user) name email; };
            ui.default-command = "log";
          };
        };
      }
    ];
  };
}
