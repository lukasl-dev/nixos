{ config, ... }:

{
  services.github-runners = {
    lukasl-nixos = {
      enable = false;
      url = "https://github.com/lukasl-dev/nixos";
      tokenFile = config.sops.secrets."github-runners/lukasl/nixos".path;
    };
  };
}
