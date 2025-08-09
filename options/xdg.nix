{ config, ... }:

let
  user = config.universe.user;
  homeDirectory = config.home-manager.users.${user.name}.home.homeDirectory;
in
{
  # TODO: add default config for browser, pdf, ...

  universe.hm = [
    {
      xdg = {
        enable = true;

        cacheHome = "${homeDirectory}/.local/cache";

        userDirs = {
          enable = true;
          createDirectories = true;
        };

        mimeApps.enable = true;
      };
    }
  ];
}
