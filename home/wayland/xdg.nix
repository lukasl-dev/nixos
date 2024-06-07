{ config, ...}:

{
  xdg = {
    enable = true;

    cacheHome = "${config.home}/.local/cache";
    configHome = "${config.home}/.config";

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
