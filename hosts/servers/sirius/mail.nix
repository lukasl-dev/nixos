# {
#   meta,
#   inputs,
#   config,
#   ...
# }:

{
  # imports = [ inputs.mailserver.nixosModule ];
  #
  # mailserver = {
  #   enable = true;
  #   fqdn = "mail.${meta.domain}";
  #   domains = [ meta.domain ];
  #
  #   loginAccounts = {
  #     "me@${meta.domain}" = {
  #       hashedPasswordFile = config.sops.secrets."user/password".path;
  #       aliases = [
  #         "contact@${meta.domain}"
  #         "git@${meta.domain}"
  #       ];
  #     };
  #   };
  # };
}
