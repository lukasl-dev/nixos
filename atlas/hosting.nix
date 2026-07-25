{ atlas, ... }:

{
  backup.host = "backup.${atlas.domain}";
  cache.host = "cache.${atlas.domain}";
  waka.host = "waka.${atlas.domain}";
}
