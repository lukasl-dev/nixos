{
  sops.secrets = {
    "ssh/private_key" = {
      owner = "lukas";
      path = "/home/lukas/.ssh/id_ed25519";
    };
  };
}
