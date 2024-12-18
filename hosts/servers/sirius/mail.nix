# { inputs, config, ... }:

{
  # imports = [ inputs.mailserver.nixosModule ];
  #
  # mailserver = {
  #   enable = true;
  #   fqdn = "mail.lukasl.dev";
  #   domains = [ "lukasl.dev" ];
  #
  #   loginAccounts = {
  #     "me@lukasl.dev" = {
  #       hashedPasswordFile = config.sops.secrets."user/password".path;
  #       aliases = [ "contact@lukasl.dev" ];
  #     };
  #   };
  # };
}
