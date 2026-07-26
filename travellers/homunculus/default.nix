{ atlas, ... }:

{
  traveller = {
    name = "homunculus";

    user = {
      name = "homunculus";
      description = "homunculus";
    };

    email = "homunculus@${atlas.domain}";

    git.user = "homunculus";
    github.user = "homunculukas";
  };
}
