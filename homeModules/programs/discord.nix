{ pkgs-unstable, ... }:

{
  home = {
    packages = [
      pkgs-unstable.vesktop
      pkgs-unstable.discord
    ];

    file = {
      ".config/vesktop/settings.json" = {
        enable = true;
        source = ../../dots/vesktop/settings.json;
        target = ".config/vesktop/settings.json";
      };
      ".config/vesktop/settings/settings.json" = {
        enable = true;
        source = ../../dots/vesktop/settings/settings.json;
        target = ".config/vesktop/settings/settings.json";
      };
    };
  };
}
