{ meta, config, ... }:

{
  sops.secrets = {
    "ssh/private_key" = {
      owner = meta.user.name;
      path = "/home/${meta.user.name}/.ssh/id_ed25519";
    };

    "user/password" = {
      neededForUsers = true;
    };

    "calcurse/client_id" = { };
    "calcurse/client_secret" = { };
    "calcurse/gmail" = { };

    "restic/secret" = { };

    "stack_auth/server_secret" = { };
  };

  sops.templates."/root/.ssh/id_ed25519" = {
    path = "/root/.ssh/id_ed25519";
    owner = "root";
    content = config.sops.placeholder."ssh/private_key";
  };
}
