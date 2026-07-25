{ atlas, ... }:

let
  node = address: { inherit address; };
in
{
  host = "mesh.${atlas.domain}";
  interface = "mesh0";
  subnet = "10.89.0.0/24";
  port = 51820;
  router = "pollux";

  nodes = {
    pollux = node "10.89.0.1";
    vega = node "10.89.0.2";
    ida = node "10.89.0.3";
    mizar = node "10.89.0.4";
  };

  proxies = {
    # HTTP services hosted on mesh nodes can be published by the router:
    #
    # home = {
    #   host = atlas.hosting.home.host;
    #   node = "mizar";
    #   port = 8123;
    # };
  };
}
