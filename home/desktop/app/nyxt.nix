{ pkgs, ... }:

{
  home = {
    packages = [ pkgs.nyxt ];

    file.".config/nyxt" = {
      enable = true;
      source = ../../../dots/nyxt;
      target = ".config/nyxt";
    };
  };
}
