{ meta, ... }:

{
  imports = [ ../../shared/nixos ];

  networking.domain = "nodes.${meta.domain}";

  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
