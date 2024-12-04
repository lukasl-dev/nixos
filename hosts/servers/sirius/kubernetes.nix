{ config, ... }:

{
  services.k3s = {
    enable = true;
    tokenFile = config.sops.secrets."k8s/token".path;
  };
}
