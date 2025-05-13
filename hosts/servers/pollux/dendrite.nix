{ config, ... }:

{
  services.dendrite = {
    enable = true;
    environmentFile = config.sops.secrets."matrix/registration_secret".path;
    settings = {
      global = {
        server_name = "lukasl.dev";
        private_key = config.sops.secrets."matrix/private_key".path;
      };
      client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
    };
  };
}
