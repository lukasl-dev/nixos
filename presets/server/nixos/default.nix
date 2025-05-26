{ meta, ... }:

{
  imports = [
    ../../shared/nixos

    ../../../nixosModules/networking/ssh/server.nix
  ];

  networking.domain = "nodes.${meta.domain}";

  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
