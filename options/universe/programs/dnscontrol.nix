{
  pkgs, config, ... }:

let
  user = config.universe.user;
  homeDir = config.home-manager.users.${user.name}.home.homeDirectory;
in
{
  environment.systemPackages = [ pkgs.unstable.dnscontrol ];

  sops.secrets = {
    "universe/cloudflare/email" = { };
    "universe/cloudflare/account_id" = { };
    "universe/cloudflare/global_api_key" = { };
  };

  sops.templates."dnscontrol/creds.json" = {
    path = "${homeDir}/nixos/dns/creds.json";
    owner = user.name;
    content = ''
      {
        "cloudflare": {
          "TYPE": "CLOUDFLAREAPI",
          "accountid": "${config.sops.placeholder."universe/cloudflare/account_id"}",
          "apikey": "${config.sops.placeholder."universe/cloudflare/global_api_key"}",
          "apiuser": "${config.sops.placeholder."universe/cloudflare/email"}"
        }
      }
    '';
  };
}
