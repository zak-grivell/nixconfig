{
  flake.homeModules.default = { pkgs, ... }: {
    programs = {
      fzf.enable = true;
      zoxide.enable = true;
      ripgrep.enable = true;
      fd.enable = true;
      bat.enable = true;
    };

    
    home.packages = with pkgs; [
      tree

      opencode
    ];
  };

   flake.modules.darwin.system = {
    homebrew.brews = [ "gemini-cli" ];
  };
}
