{
  sops.secrets = {
    "ssh/private_key" = {
      owner = "lukas";
      path = "/home/lukas/.ssh/id_ed25519";
    };
    "user/password" = {
      neededForUsers = true;
    };
    "k8s/token" = { };

    "cloudflare/email" = { };
    "cloudflare/global_api_key" = { };

    "harmonia/secret" = { };
    "harmonia/public_key" = { };
  };
}
