{
  security.sudo.enable = true;

  planet =
    let
      group = "wheel";
    in
    {
      steward.groups = [ group ];
      roles.operator.groups = [ group ];
    };
}
