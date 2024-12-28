{ config, ... }:

{
  services.github-runners = {
    lukasl-nixos = {
      enable = true;
      url = "https://github.com/lukasl-dev/nixos";
      tokenFile = config.sops.secrets."github-runners/lukasl/nixos".path;
    };
  };
}
