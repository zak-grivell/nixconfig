{
   flake.homeModules.disabled = { pkgs, ...}: {
     home.packages = with pkgs; [
       obsidian
    ];
  };
}
