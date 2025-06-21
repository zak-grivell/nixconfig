# A module that automatically imports everything else in the parent folder,
# except default.nix and anything inside the 'hidden' folder.
{
  imports =
    with builtins;
    map
      (fn: ./${fn})
      (filter
        (fn:
          fn != "default.nix"
          && fn != "hidden"
          && match "hidden/.*" fn == null
        )
        (attrNames (readDir ./.))
      );
}
