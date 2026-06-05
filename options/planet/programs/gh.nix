{ pkgs, ... }:

{
  planet.hm = [
    {
      programs.gh = {
        enable = true;
        extensions = [ pkgs.gh-dash ];
      };

      programs.gh-dash.enable = true;
    }
  ];
}
