rec {
  container = domain;
  domain = "onyx.md";

  hostName = builtins.replaceStrings [ "." ] [ "-" ] domain;
  router = name: "${name}-${hostName}";

  address = {
    local = "10.100.0.3";
    host = "10.100.0.1";
  };
}
