{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.vim
          pkgs.nerd-fonts.jetbrains-mono
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.primaryUser = "hxyulin";

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.defaults = {
        # Disable mouse accel
        ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleShowAllFiles = true;

        # Disable recent apps
        WindowManager.AutoHide = true;
        WindowManager.EnableStandardClickToShowDesktop = false;

        controlcenter.BatteryShowPercentage = true;
        dock.persistent-apps = [
          {
            app = "/Applications/Zen.app";
          }
          {
            app = "/Applications/Ghostty.app";
          }
        ];
        dock.persistent-others = [];
        dock.show-recents = false;
        dock.wvous-bl-corner = 1;
        dock.wvous-br-corner = 1;
        dock.wvous-tl-corner = 1;
        dock.wvous-tr-corner = 1;
        dock.tilesize = 48;
        finder.AppleShowAllExtensions = true;
        finder.AppleShowAllFiles = true;
        finder.NewWindowTarget = "Home";
        finder.ShowExternalHardDrivesOnDesktop = false;
        finder.ShowHardDrivesOnDesktop = false;
        finder.ShowRemovableMediaOnDesktop = false;
        hitoolbox.AppleFnUsageType = "Do Nothing";
        menuExtraClock.Show24Hour = true;

        screencapture.location = "~/Pictures/Screenshots";
        
        dock.mru-spaces = false;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
      };

      environment.variables = {
        EDITOR = "nvim";
      };

      fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
      ];

      homebrew = {
        enable = true;
        casks = [
          "ghostty"
        ];
        brews = [
          "neovim"
          "starship"
          "gh"
          "zoxide"
          "btop"
          "fastfetch"
        ];
      };

      networking.localHostName = "HxyulinMac";

      power.sleep = {
        computer = 60;
        display = 30;
      };

      security.pam.services.sudo_local.reattach = true;
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#hxyulins-MacBook-Pro
    darwinConfigurations."HxyulinMac" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ configuration ];
    };
  };
}
