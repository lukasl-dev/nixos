{ atlas, ... }:

{
  anki.host = "anki.${atlas.domain}";
  autoconfig.host = "autoconfig.${atlas.domain}";
  backup.host = "backup.${atlas.domain}";
  books.host = "books.${atlas.domain}";
  cal.host = "cal.${atlas.domain}";
  cache.host = "cache.${atlas.domain}";
  forge.host = "forge.${atlas.domain}";
  home.host = "home.${atlas.domain}";
  household.host = "household.${atlas.domain}";
  mail.host = "mail.${atlas.domain}";
  notes.host = "notes.${atlas.domain}";
  rspamd.host = "rspamd.${atlas.domain}";
  vault.host = "vault.${atlas.domain}";
  waka.host = "waka.${atlas.domain}";
  www.host = atlas.domain;
  yam.host = "yam.${atlas.domain}";
}
