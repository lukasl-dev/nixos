{
  pkgs,
  inputs,
  ...
}:

let
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/etc/sops/age/keys.txt";
  };
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];
  inherit sops;

  environment = {
    systemPackages = [ pkgs.unstable.sops ];
    variables.SOPS_AGE_KEY_FILE = sops.age.keyFile;
  };

  universe.hm = [
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      inherit sops;
    }
  ];
}
