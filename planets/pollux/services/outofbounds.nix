{ inputs, config, ... }:

{
  imports = [ inputs.outofbounds.nixosModules.default ];

  services.outofbounds = {
    enable = true;
    interval = "daily";

    settings = config.sops.secrets."planets/pollux/outofbounds/settings".path;
  };

  sops = {
    secrets."planets/pollux/outofbounds/settings" = {
      owner = "outofbounds";
    };
  };
}
