let
  thisDir = builtins.toString ./.;
  entries = builtins.readDir thisDir;
in
{
  imports = builtins.map (name: ./${name}) (
    builtins.filter (
      name:
      name != "default.nix"
      && name != "hidden"
      && (entries.${name} == "regular" || entries.${name} == "directory" || entries.${name} == "symlink")
    ) (builtins.attrNames entries)
  );
}
