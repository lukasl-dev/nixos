{ atlas, ... }:

{
  traveller = rec {
    name = "prime";

    user = {
      name = "lukas";
      description = "Lukas Leeb";
    };

    email = "me@${atlas.domain}";

    keys = {
      private = atlas.secrets.universe [
        "travellers"
        "prime"
        "keys"
        "private"
      ];
      public = builtins.readFile ./id_ed25519.pub;
    };

    git.user = "lukasl-dev";
    github.user = git.user;
  };
}
