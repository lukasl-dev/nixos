{ meta, config, ... }:

{
  sops = {
    secrets."pypi/token" = { };

    templates.".pypirc" = {
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
  };
}
