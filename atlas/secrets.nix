{
  universe = path: builtins.concatStringsSep "/" ([ "universe" ] ++ path);
  planet = path: builtins.concatStringsSep "/" ([ "planet" ] ++ path);
}
