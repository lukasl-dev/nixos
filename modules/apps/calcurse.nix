{
  meta,
  config,
  pkgs-unstable,
  ...
}:

{
  environment.systemPackages = with pkgs-unstable; [
    calcurse
  ];

  # calcurse
  sops.templates."calcurse/caldav/config" = {
    path = "/home/${meta.user.name}/.config/calcurse/caldav/config";
    owner = meta.user.name;
    content = ''
      [General]
      Hostname = apidata.googleusercontent.com
      Path = /caldav/v2/${config.sops.placeholder."calcurse/gmail"}/events/
      AuthMethod = oauth2
      SyncFilter = cal
      DryRun = No

      [OAuth2]

      ClientID = ${config.sops.placeholder."calcurse/client_id"}
      ClientSecret = ${config.sops.placeholder."calcurse/client_secret"}
      Scope = https://www.googleapis.com/auth/calendar
      RedirectURI = http://127.0.0.1
    '';
  };
}
