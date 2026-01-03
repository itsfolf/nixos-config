{
  inputs,
  hostName,
  ...
}:
{
  networking.hostName = hostName;

  system.configurationRevision = inputs.self.rev or "dirty";
}
