{ atlas, ... }:

{
  anki.host = "anki.${atlas.domain}";
  autoconfig.host = "autoconfig.${atlas.domain}";
  backup.host = "backup.${atlas.domain}";
  books.host = "books.${atlas.domain}";
  cal.host = "cal.${atlas.domain}";
  cache.host = "cache.${atlas.domain}";
  household.host = "household.${atlas.domain}";
  mail.host = "mail.${atlas.domain}";
  rspamd.host = "rspamd.${atlas.domain}";
  waka.host = "waka.${atlas.domain}";
}
