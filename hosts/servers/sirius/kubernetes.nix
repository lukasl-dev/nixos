{ config, pkgs-unstable, ... }:

{
  services.k3s = {
    enable = true;

    clusterInit = true;
    role = "server";
    tokenFile = config.sops.secrets."k8s/token".path;

    extraFlags = [ "--disable local-storage" ];
  };

  networking.firewall = {
    allowedTCPPorts = [
      6443
      2379
      2380
    ];
    allowedUDPPorts = [ 8472 ];
  };

  environment.systemPackages = with pkgs-unstable; [
    kubectl
    kubernetes

    helmfile
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
  ];
}
