{ meta, ... }:

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

    "k8s/token" = { };

    "cloudflare/email" = { };
    "cloudflare/global_api_key" = { };

    "harmonia/secret" = { };
    "harmonia/public_key" = { };

    "vaultwarden/key" = {
      owner = meta.user.name;
      path = "/var/lib/bitwarden_rs/rsa_key.pem";
    };

    "github-runners/lukasl/nixos" = { };
  };
}
