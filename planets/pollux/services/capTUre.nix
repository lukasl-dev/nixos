{ inputs, ... }:

{
  imports = [ inputs.capTUre.nixosModules.capTUre ];

  services.capTUre = {
    enable = true;
    schedule = {
      mo_08_stats = {
        weekday = "Monday";
        start = "08:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };
      mo_10_swe = {
        weekday = "Monday";
        start = "10:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };
      mo_12_thinf = {
        weekday = "Monday";
        start = "12:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };
      mo_14_pp = {
        weekday = "Monday";
        start = "14:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };

      tu_13_os = {
        weekday = "Tuesday";
        start = "13:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };
      tu_15_os_ue = {
        weekday = "Tuesday";
        start = "15:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };

      wed_12_iml = {
        weekday = "Wednesday";
        start = "12:00";
        duration = 2 * 60;
        channel = "fav1";
      };
      wed_13_thinf = {
        weekday = "Wednesday";
        start = "13:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };

      th_15_os_ue = {
        weekday = "Thursday";
        start = "15:00";
        duration = 2 * 60;
        channel = "informatikhoersaal";
      };
    };
  };
}
