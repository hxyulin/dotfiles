{
  description = "hxyulin nix-darwin system flake";

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
      
      # auto optimize the store
      nix.optimise.automatic = true;
      nix.gc.automatic = true;

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
        CustomUserPreferences = {
          "com.apple.AdLib" = {
            allowApplePersonalizedAdvertising = false;
          };
          "com.apple.finder" = {
            SidebarShowingiCloudDesktop = false;
            FXICloudDriveEnabled = false;
          };
          "com.apple.symbolichotkeys" = {
            AppleSymbolicHotKeys = {
              "60" = { enabled = false; };  # Ctrl+Space — select previous input source
              "64" = { enabled = false; };  # Cmd+Space — Spotlight search
              "65" = { enabled = false; };  # Cmd+Alt+Space — Finder search window
            };
          };
        };

        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

        # Disable mouse accel
        ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;
        NSGlobalDomain.ApplePressAndHoldEnabled = false;
        NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
        NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
        NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
        NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
        NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
        NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
        NSGlobalDomain.NSWindowShouldDragOnGesture = true;
        NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleShowAllFiles = true;

        # Keyboard settings
        NSGlobalDomain."com.apple.keyboard.fnState" = true;
        NSGlobalDomain.AppleKeyboardUIMode = 3;
        NSGlobalDomain.InitialKeyRepeat = 15;
        NSGlobalDomain.KeyRepeat = 2;

        # Disable auto-correction
        NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
        NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
        NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;

        # Disable recent apps
        WindowManager.AutoHide = true;
        WindowManager.EnableStandardClickToShowDesktop = false;

        controlcenter.BatteryShowPercentage = true;

        dock.mru-spaces = false;
        dock.persistent-apps = [];
        dock.persistent-others = [];
        dock.show-recents = false;
        dock.wvous-bl-corner = 1;
        dock.wvous-br-corner = 1;
        dock.wvous-tl-corner = 1;
        dock.wvous-tr-corner = 1;
        dock.tilesize = 48;

        finder.AppleShowAllExtensions = true;
        finder.AppleShowAllFiles = true;
        finder.FXPreferredViewStyle = "clmv";
        finder.ShowPathbar = true;
        finder.ShowStatusBar = true;
        finder.NewWindowTarget = "Home";
        finder.ShowExternalHardDrivesOnDesktop = false;
        finder.ShowHardDrivesOnDesktop = false;
        finder.ShowMountedServersOnDesktop = false;
        finder.ShowRemovableMediaOnDesktop = false;
        finder.FXDefaultSearchScope = "SCcf";
        finder.FXEnableExtensionChangeWarning = false;
        finder.FXRemoveOldTrashItems = true;
        finder._FXSortFoldersFirst = true;
        finder._FXSortFoldersFirstOnDesktop = true;
        finder.CreateDesktop = false;

        hitoolbox.AppleFnUsageType = "Do Nothing";
        menuExtraClock.Show24Hour = true;

        trackpad.Clicking = true;
        trackpad.TrackpadThreeFingerDrag = true;

        screencapture.location = "~/Pictures/Screenshots";
        screensaver.askForPasswordDelay = 0;
        
        loginwindow.GuestEnabled = false;

        LaunchServices.LSQuarantine = false;
        universalaccess.reduceMotion = true;
      };

      system.startup.chime = false;

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
          "raycast"
        ];
        brews = [
          # Editors & shells
          "neovim"
          "fish"
          # Dev tools
          "gh"
          "just"
          "watchexec"
          "bob"
          "fnm"
          # CLI essentials
          "starship"
          "zoxide"
          "eza"
          "ripgrep"
          "fd"
          "bat"
          "jq"
          "age"
          "sd"
          "git-delta"
          # Fuzzy finding & shell history
          "fzf"
          "atuin"
          # Git tools
          "lazygit"
          "difftastic"
          "git-absorb"
          # File management
          "yazi"
          # HTTP & networking
          "xh"
          "doggo"
          "gping"
          "bandwhich"
          # Text processing
          "grex"
          # Terminal multiplexer
          "zellij"
          # System monitoring & info
          "btop"
          "procs"
          "dust"
          "dufs"
          "tokei"
          "hyperfine"
          "fastfetch"
          "tealdeer"
        ];
        masApps = {
          Xcode = 497799835;
          WeChat = 836500024;
        };
      };

      networking.localHostName = "hxyulin-mac";
      networking.knownNetworkServices = ["Wi-Fi"];
      networking.dns = [
        "8.8.8.8"
        "8.8.4.4"
      ];

      networking.applicationFirewall.enable = true;
      networking.applicationFirewall.enableStealthMode = true;

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
    # $ darwin-rebuild build --flake .#hxyulin-mac
    darwinConfigurations."hxyulin-mac" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ configuration ];
    };
  };
}
