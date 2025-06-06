{
  meta,
  inputs,
  pkgs-unstable,
  ...
}:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs-unstable; [ sops ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${meta.user.name}/.config/sops/age/keys.txt";
}
