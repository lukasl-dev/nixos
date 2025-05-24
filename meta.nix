rec {
  stateVersion = "25.05";

  dir = "/home/${user.name}/nixos";

  user = {
    name = "lukas";
    fullName = "Lukas Leeb";
  };

  domain = "lukasl.dev";

  git = {
    username = "lukasl-dev";
  };

  time = {
    zone = "Europe/Vienna";
  };

  keyboard = {
    layout = "us";
    variant = "";
  };

  cuda = false;
}
