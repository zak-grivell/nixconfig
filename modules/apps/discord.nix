{ ... }: {
   flake.modules.homeManager.zakbook = { pkgs, ...}: {
     home.packages = with pkgs; [
      discord
    ];
  };
}
