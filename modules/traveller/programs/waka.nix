{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) traveller;
in
{
  options.traveller.programs.waka = {
    enable = lib.mkEnableOption "Wakatime cli";
    apiKey = lib.mkOption {
      type = lib.types.str;
      default = "travellers/${traveller.name}/waka/apiKey";
      description = "Agenix secret containing this traveller's WakaTime API key.";
    };
  };

  config.traveller.modules = [
    (
      { config, pkgs, ... }:

      let
        inherit (config) age;
        apiKey = traveller.programs.waka.apiKey;
        wakaConfig = "travellers/${traveller.name}/waka/config";
      in
      {
        age.secrets = {
          ${apiKey} = {
            rekeyFile = ../../.. + "/secrets/${apiKey}.age";
            intermediary = true;
          };

          ${wakaConfig} = {
            rekeyFile = ../../.. + "/secrets/${wakaConfig}.age";
            owner = traveller.user.name;
            mode = "0400";

            generator = {
              dependencies.apiKey = age.secrets.${apiKey};
              script =
                { decrypt, deps, ... }:
                ''
                  api_key="$(${decrypt} "${deps.apiKey.file}")"

                  printf '[settings]\n'
                  printf 'api_key=%s\n' "$api_key"
                  printf 'api_url=%s\n' ${lib.escapeShellArg atlas.hosting.waka.host}
                '';
            };
          };
        };

        users.users.${traveller.user.name}.packages = [
          (pkgs.symlinkJoin {
            name = "wakatime-cli-${traveller.name}";
            paths = [ pkgs.wakatime-cli ];
            nativeBuildInputs = [ pkgs.makeWrapper ];

            postBuild = ''
              wrapProgram "$out/bin/wakatime-cli" \
                --add-flags "--config ${age.secrets.${wakaConfig}.path}"
            '';
          })
        ];
      }
    )
  ];
}
