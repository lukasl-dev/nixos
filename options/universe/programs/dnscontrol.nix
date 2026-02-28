{
  pkgs,
  config,
  ...
}:

let
  user = config.universe.user;
  homeDir = config.home-manager.users.${user.name}.home.homeDirectory;
in
{
  environment.systemPackages = [ pkgs.unstable.dnscontrol ];

  age.secrets = {
    "universe/cloudflare/email" = {
      rekeyFile = ../../../secrets/universe/cloudflare/email.age;
      intermediary = true;
    };
    "universe/cloudflare/account_id" = {
      rekeyFile = ../../../secrets/universe/cloudflare/account_id.age;
      intermediary = true;
    };
    "universe/cloudflare/global_api_key" = {
      rekeyFile = ../../../secrets/universe/cloudflare/global_api_key.age;
      intermediary = true;
    };

    "dnscontrol/creds.json" = {
      rekeyFile = ../../../secrets/dnscontrol/creds_json.age;
      generator = {
        dependencies = {
          email = config.age.secrets."universe/cloudflare/email";
          accountId = config.age.secrets."universe/cloudflare/account_id";
          apiKey = config.age.secrets."universe/cloudflare/global_api_key";
        };
        script =
          { decrypt, deps, ... }:
          ''
            email="$(${decrypt} "${deps.email.file}")"
            account_id="$(${decrypt} "${deps.accountId.file}")"
            api_key="$(${decrypt} "${deps.apiKey.file}")"

            cat <<EOF
            {
              "cloudflare": {
                "TYPE": "CLOUDFLAREAPI",
                "accountid": "$account_id",
                "apikey": "$api_key",
                "apiuser": "$email"
              }
            }
            EOF
          '';
      };
      path = "${homeDir}/nixos/dns/creds.json";
      owner = user.name;
    };
  };
}
