{
  config,
  inputs,
  pkgs-unstable,
  ...
}:

{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs-unstable; [ sops ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/etc/sops/age/keys.txt";

  environment.sessionVariables = {
    SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
  };
}
