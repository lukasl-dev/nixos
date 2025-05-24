{
  users = {
    users = {
      build = {
        isSystemUser = true;
        createHome = true;
        group = "build";

        openssh.authorizedKeys.keys = [
          (builtins.readFile ../../../dots/ssh/id_ed25519.pub)
        ];
      };
    };

    groups = {
      build = { };
    };
  };
}
