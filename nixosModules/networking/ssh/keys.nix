{ meta, ... }:

{
  sops.secrets = {
    "ssh/private_key" = {
      owner = meta.user.name;
      path = "/home/${meta.user.name}/.ssh/id_ed25519";
    };
  };
}
