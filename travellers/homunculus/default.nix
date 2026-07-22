{ atlas, ... }:

{
  traveller = {
    name = "homunculus";

    user = {
      name = "homunculus";
      description = "homunculus";
    };

    email = "homunculus@${atlas.domain}";

    keys = {
      private = atlas.secrets.universe [
        "travellers"
        "homunculus"
        "keys"
        "private"
      ];
      public = builtins.readFile ./id_ed25519.pub;
    };

    git.user = "homunculus";
    github.user = "homunculukas";
  };
}
