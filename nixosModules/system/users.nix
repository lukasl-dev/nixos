{
  meta,
  config,
  pkgs,
  ...
}:

{
  sops.secrets."user/password" = {
    neededForUsers = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        openssh.authorizedKeys.keys = [ (builtins.readFile ../../dots/ssh/id_ed25519.pub) ];
        hashedPasswordFile = config.sops.secrets."user/password".path;
      };

      ${meta.user.name} = {
        isNormalUser = true;
        description = meta.user.fullName;
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "wireshark"
        ];
        hashedPasswordFile = config.sops.secrets."user/password".path;
        openssh.authorizedKeys.keys = [ (builtins.readFile ../../dots/ssh/id_ed25519.pub) ];
      };
    };
  };
}
