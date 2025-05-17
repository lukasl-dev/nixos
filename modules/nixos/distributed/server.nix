{
  users = {
    users = {
      nixremote = {
        isSystemUser = true;
        createHome = true;
        group = "nixremote";

        openssh.authorizedKeys.keys = [ (builtins.readFile ../../../dots/ssh/id_ed25519.pub) ];
      };
    };

    groups = {
      nixremote = { };
    };
  };
}
