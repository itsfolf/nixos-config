{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.modules.commonModules.default
  ];
}
