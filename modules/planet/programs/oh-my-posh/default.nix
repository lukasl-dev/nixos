{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;

  settings = builtins.fromJSON (builtins.readFile ./settings.json);
  settingsFile =
    (pkgs.formats.json { }).generate "oh-my-posh-config.json"
      settings;
  exe = lib.getExe pkgs.oh-my-posh;
  init = shell: ''
    eval "$(${exe} init ${shell} --config ${settingsFile})"
  '';
in
{
  environment.systemPackages = [ pkgs.oh-my-posh ];

  hjem.users = atlas.travellers.forEach planet (_: {
    files.".bashrc".text = lib.mkOrder 2000 (init "bash");
    rum.programs.zsh.initConfig = lib.mkOrder 2000 (init "zsh");

    xdg.config.files."oh-my-posh/config.json".source = settingsFile;
  });
}
