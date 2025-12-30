rec {
  container = domain;
  domain = "lukasl.dev";

  hostName = builtins.replaceStrings [ "." ] [ "-" ] domain;
  router = name: "${name}-${hostName}";

  address = {
    local = "10.100.0.2";
    host = "10.100.0.1";
  };
}
