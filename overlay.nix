final: prev:
let
  mkPackage = name: {
    inherit name;
    value = final.callPackage ./packages/${name} { };
  };

  names = builtins.attrNames (builtins.readDir ./packages);
in
builtins.listToAttrs (map mkPackage names)
