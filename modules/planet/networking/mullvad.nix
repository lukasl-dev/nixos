{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.networking) mullvad;

  daemonPackage = pkgs.unstable.mullvad;
  guiPackage = pkgs.unstable.mullvad-vpn;
in
{
  options.planet.networking.mullvad = {
    enable = lib.mkEnableOption "Mullvad VPN" // {
      default = planet.desktop.enable;
      defaultText = lib.literalExpression "config.planet.desktop.enable";
    };
  };

  config = lib.mkIf mullvad.enable {
    services.mullvad-vpn = {
      enable = true;
      package = daemonPackage;
    };

    environment.systemPackages = lib.optionals planet.desktop.enable [
      guiPackage
      pkgs.unstable.mullvad-browser
    ];

    planet = {
      desktop.autoStart = [ (lib.getExe guiPackage) ];

      shell.aliases.novpn = "mullvad-exclude";
    };

    systemd.services.nix-daemon =
      let
        excludeNixDaemon =
          pkgs.writeShellScript "mullvad-exclude-nix-daemon" # bash
            ''
                pid="''${MAINPID:-}"

                if [[ -z "$pid" || "$pid" == 0 ]]; then
                  echo >&2 \
                    "warning: nix-daemon has no MAINPID to exclude from Mullvad"
                  exit 1
                fi

                for _ in {1..10}; do
              if ${daemonPackage}/bin/mullvad split-tunnel add "$pid"; then
                    exit 0
                  fi

                  ${lib.getExe' pkgs.coreutils "sleep"} 1
                done

                echo "warning: failed to exclude nix-daemon from Mullvad" >&2
                exit 1
            '';
      in
      {
        wants = [ "mullvad-daemon.service" ];
        after = [ "mullvad-daemon.service" ];
        serviceConfig.ExecStartPost = lib.mkAfter [ "-${excludeNixDaemon}" ];
      };
  };
}
