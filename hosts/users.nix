{
  meta,
  pkgs,
  config,
  ...
}:

{
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        openssh.authorizedKeys.keys = [ (builtins.readFile ../dots/ssh/id_ed25519.pub) ];
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
        openssh.authorizedKeys.keys = [ (builtins.readFile ../dots/ssh/id_ed25519.pub) ];
      };
    };
  };
}
