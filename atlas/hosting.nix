{ atlas, ... }:

{
  cache.host = "cache.${atlas.domain}";
  waka.host = "waka.${atlas.domain}";
}
