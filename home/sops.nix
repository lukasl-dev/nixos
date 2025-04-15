{ inputs, meta, ... }:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${meta.user.name}/.config/sops/age/keys.txt";
}
