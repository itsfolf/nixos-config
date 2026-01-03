{ lib }:

let
  # Import all .nix files and directories from a path
  importDir =
    path: fn:
    let
      entries = builtins.readDir path;

      # Get directories
      onlyDirs = lib.filterAttrs (_name: type: type == "directory") entries;
      dirPaths = lib.mapAttrs (name: type: {
        path = path + "/${name}";
        inherit type;
      }) onlyDirs;

      # Get .nix files (without extension)
      nixPaths = builtins.removeAttrs (lib.mapAttrs' (
        name: type:
        let
          nixName = builtins.match "(.*)\\.nix" name;
        in
        {
          name = if type == "directory" || nixName == null then "__junk" else (builtins.head nixName);
          value = {
            path = path + "/${name}";
            type = type;
          };
        }
      ) entries) [ "__junk" ];

      # Nix files take precedence over directories
      combined = dirPaths // nixPaths;
    in
    lib.optionalAttrs (builtins.pathExists path) (fn combined);

  # Extract just the paths from the entries
  entriesPath = lib.mapAttrs (_name: { path, type }: path);

  # Discover modules from a base path
  loadModules' =
    { src }:
    let
      path = src + "/modules";
      moduleDirs = builtins.attrNames (
        lib.filterAttrs (_name: value: value == "directory") (builtins.readDir path)
      );
    in
    lib.optionalAttrs (builtins.pathExists path) (
      lib.genAttrs moduleDirs (
        name:
        lib.mapAttrs (
          _name: moduleDir: # injectPublisherArgs
          moduleDir
        ) (importDir (path + "/${name}") entriesPath)
      )
    );

  mkModules =
    modules:
    modules
    // {
      default = {
        imports = lib.attrsets.attrValues modules;
      };
    };

  # Top-level function to load all modules
  loadModules =
    { inputs }:
    let
      modules = loadModules' {
        src = inputs.self;
      };
      commonModules = modules.common or { };
      nixosModules = modules.nixos or { };
      homeModules = modules.home or { };
    in
    {
      commonModules = mkModules commonModules;
      nixosModules = mkModules nixosModules;
      homeModules = mkModules homeModules;
    };

in
{
  inherit loadModules;
}
