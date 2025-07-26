{
  meta,
  config,
  pkgs-unstable,
  ...
}:

{
  environment.systemPackages = [ pkgs-unstable.dnscontrol ];

  sops.secrets = {
    "cloudflare/email" = { };
    "cloudflare/account_id" = { };
    "cloudflare/global_api_key" = { };
  };

  sops.templates."dnscontrol/creds.json" = {
    path = "${meta.dir}/dns/creds.json";
    owner = meta.user.name;
    content = ''
      {
        "cloudflare": {
          "TYPE": "CLOUDFLAREAPI",
          "accountid": "${config.sops.placeholder."cloudflare/account_id"}",
          "apikey": "${config.sops.placeholder."cloudflare/global_api_key"}",
          "apiuser": "${config.sops.placeholder."cloudflare/email"}"
        }
      }
    '';
  };
}
