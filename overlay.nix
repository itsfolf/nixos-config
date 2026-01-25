let
  mkPackage = name: final: {
    inherit name;
    value = final.callPackage ./packages/${name} { };
  };

  names = builtins.attrNames (builtins.readDir ./packages);
in
{
  overlay = final: prev: builtins.listToAttrs (map (name: mkPackage name final) names);
  packageNames = names;
}
