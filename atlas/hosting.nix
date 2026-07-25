{ atlas, ... }:

{
  anki.host = "anki.${atlas.domain}";
  backup.host = "backup.${atlas.domain}";
  books.host = "books.${atlas.domain}";
  cal.host = "cal.${atlas.domain}";
  cache.host = "cache.${atlas.domain}";
  household.host = "household.${atlas.domain}";
  waka.host = "waka.${atlas.domain}";
}
