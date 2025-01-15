{ meta, config, ... }:

{
  sops.secrets = {
    "ssh/private_key" = {
      owner = meta.user.name;
      path = "/home/${meta.user.name}/.ssh/id_ed25519";
    };

    "user/password" = {
      neededForUsers = true;
    };

    "calcurse/client_id" = { };
    "calcurse/client_secret" = { };
    "calcurse/gmail" = { };

    "pypi/password" = { };
    "pypi/token" = { };
  };

  # pypyrc
  sops.templates.".pypirc" = {
    path = "/home/${meta.user.name}/.pypirc";
    owner = meta.user.name;
    content = ''
      [pypi]
      username = __token__
      password = ${config.sops.placeholder."pypi/token"}

      [distutils]
      index-servers =
          pypi
          testpypi

      [pypi]
      repository = https://upload.pypi.org/legacy/

      [testpypi]
      repository = https://test.pypi.org/legacy/
    '';
  };
}
