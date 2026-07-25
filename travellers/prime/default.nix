{ atlas, ... }:

{
  imports = [
    ./desktop

    ./shell.nix
  ];

  traveller = rec {
    name = "prime";

    user = {
      name = "lukas";
      description = "Lukas Leeb";
    };

    email = "me@${atlas.domain}";

    git.user = "lukasl-dev";
    github.user = git.user;

    programs = {
      pi.enable = true;
      waka.enable = true;
    };
  };
}
