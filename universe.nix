{ config, ... }:

let
  inherit (config) age;
  inherit (config.planet) user;

  secrets =
    let
      s = sub: builtins.concatStringsSep "/" ([ "universe" ] ++ sub);
    in
    {
      user = {
        password = s [
          "user"
          "password"
        ];
      };
      ssh = {
        default = {
          privateKey = s [
            "ssh"
            "default"
            "privateKey"
          ];
        };
        g0_complang_tuwien_ac_at = {
          privateKey = s [
            "ssh"
            "g0.complang.tuwien.ac.at"
            "privateKey"
          ];
        };
      };
      attic = {
        token = s [
          "attic"
          "token"
        ];
      };
      opencode = {
        apiKey = s [
          "opencode"
          "apiKey"
        ];
      };
      exa = {
        apiKey = s [
          "exa"
          "apiKey"
        ];
      };
      anki = {
        username = s [
          "anki"
          "username"
        ];
        key = s [
          "anki"
          "key"
        ];
      };
    };
in
{
  planet = {
    domain = "lukasl.dev";

    user = {
      name = "lukas";
      password = age.secrets.${secrets.user.password}.path;
      description = "Lukas Leeb";
    };

    ssh = {
      default = {
        publicKey = builtins.readFile ./id_ed25519.pub;
        privateKey = age.secrets.${secrets.ssh.default.privateKey}.path;
      };
      "g0.complang.tuwien.ac.at" = {
        privateKey = age.secrets.${secrets.ssh.g0_complang_tuwien_ac_at.privateKey}.path;
      };
    };

    attic = {
      token = age.secrets.${secrets.attic.token}.path;
    };

    programs = {
      git = {
        user = {
          name = "lukasl-dev";
          email = "git@lukasl.dev";
        };
      };

      jujutsu = {
        user = {
          name = "lukasl-dev";
          email = "git@lukasl.dev";
        };
      };

      pi = {
        secrets = {
          opencode = age.secrets.${secrets.opencode.apiKey}.path;
          exa = age.secrets.${secrets.exa.apiKey}.path;
        };
      };

      anki = {
        username = age.secrets.${secrets.anki.username}.path;
        key = age.secrets.${secrets.anki.key}.path;
      };
    };
  };

  age.secrets = {
    # user
    ${secrets.user.password}.rekeyFile = ./secrets/universe/user/password.age;

    # ssh
    ${secrets.ssh.default.privateKey} = {
      rekeyFile = ./secrets/universe/ssh/default/privateKey.age;
      owner = user.name;
    };
    ${secrets.ssh.g0_complang_tuwien_ac_at.privateKey} = {
      rekeyFile = ./secrets/universe/ssh/g0.complang.tuwien.ac.at/privateKey.age;
      owner = user.name;
    };

    # attic
    ${secrets.attic.token}.rekeyFile = ./secrets/universe/attic/token.age;

    # programs
    ${secrets.opencode.apiKey} = {
      rekeyFile = ./secrets/universe/opencode/apiKey.age;
      owner = user.name;
    };
    ${secrets.exa.apiKey} = {
      rekeyFile = ./secrets/universe/exa/apiKey.age;
      owner = user.name;
    };

    ${secrets.anki.username}.rekeyFile = ./secrets/universe/anki/username.age;
    ${secrets.anki.key}.rekeyFile = ./secrets/universe/anki/key.age;
  };
}
