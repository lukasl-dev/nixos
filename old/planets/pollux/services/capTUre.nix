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
      we_13_is_gm1 = {
        weekday = "Wednesday";
        start = "13:00";
        duration = 2 * 60;
        channel = "gm1";
      };
      th_14_is_gm1 = {
        weekday = "Thursday";
        start = "14:00";
        duration = 2 * 60;
        channel = "gm1";
      };
      tu_17_iq_ei4 = {
        weekday = "Tuesday";
        start = "17:00";
        duration = 2 * 60;
        channel = "ei4";
      };
      we_17_iq_ei3 = {
        weekday = "Wednesday";
        start = "17:00";
        duration = 2 * 60;
        channel = "ei3";
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
      fr_2026_03_13_08_exercise_presentation = {
        start = "2026-03-13 08:00:00";
        duration = 2 * 60;
        channel = "gm1";
      };
      th_2026_06_11_18_schachermayer = {
        start = "2026-06-11 18:00:00";
        duration = 60;
        channel = "fh8";
      };
    };
  };
}
