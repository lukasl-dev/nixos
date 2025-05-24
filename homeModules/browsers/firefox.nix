{ pkgs-unstable, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs-unstable.firefox;

    profiles.default = {
      isDefault = true;
    };
  };
}
