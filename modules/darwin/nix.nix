{
  flake.modules.darwin.system = {
    nix.gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 1d";
    };

    nix.optimise.automatic = true;
#     nix.settings.access-tokens = [
#   "github.com=$(cat /run/secrets/github_token)"
# ];
nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      trusted-users = [ "root" "zakgrivell" ];
    };
  };
}
