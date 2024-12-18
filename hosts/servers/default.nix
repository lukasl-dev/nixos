{
  meta,
  lib,
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ../default.nix

    ./ssh.nix
  ];

  networking.domain = "nodes.${meta.domain}";

  home-manager.users.${meta.user.name} = lib.mkDefault (
    import ../../home/headless { inherit inputs pkgs pkgs-unstable; }
  );

  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL) NOPASSWD: ALL
    '';
  };
}
