{ config, ... }:

let
  inherit (config) traveller;
in
{
  config.traveller.modules = [
    (
      { pkgs, ... }:

      let
        configFile = (pkgs.formats.toml { }).generate "jujutsu-config.toml" {
          user = {
            name = traveller.git.user;
            inherit (traveller) email;
          };

          ui.default-command = "log";
        };
      in
      {
        hjem.users.${traveller.user.name} = {
          packages = [ pkgs.jujutsu ];
          xdg.config.files."jj/config.toml".source = configFile;
        };
      }
    )
  ];
}
