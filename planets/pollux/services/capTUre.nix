{ inputs, ... }:

{
  imports = [ inputs.capTUre.nixosModules.capTUre ];

  services.capTUre = {
    enable = true;
    weekly = {
      tu_09_ea_quer = {
        weekday = "Tuesday";
        start = "09:00";
        duration = 2 * 60;
        channel = "ei8";
      };
      th_10_ea_quer = {
        weekday = "Thursday";
        start = "10:00";
        duration = 2 * 60;
        channel = "ei8";
      };
    };
    dates = {
      tu_2026_03_03_09_first_lecture = {
        start = "2026-03-03 09:00:00";
        duration = 2 * 60;
        channel = "ei8";
      };
      fr_2026_03_06_10_hv_inf = {
        start = "2026-03-06 10:00:00";
        duration = 2 * 60;
        channel = "fav1";
      };
      fr_2026_03_13_10_hv_inf = {
        start = "2026-03-13 10:00:00";
        duration = 2 * 60;
        channel = "fav1";
      };
    };
  };
}
