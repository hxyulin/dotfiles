{
  description = "hxyulin nix-darwin system flake";

  inputs = {
    # Pinned to the 26.05 stable release to match nix-darwin 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {

      #############################################################
      ## Nix / system meta
      #############################################################

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 7;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.primaryUser = "hxyulin";

      nix.settings = {
        # Necessary for using flakes on this system.
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "root" "hxyulin" ];

        # Extra binary cache so common packages don't get built from source.
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      # Auto-optimise the store and garbage collect weekly.
      nix.optimise.automatic = true;
      nix.gc = {
        automatic = true;
        interval = { Weekday = 7; Hour = 3; Minute = 15; };
        options = "--delete-older-than 30d";
      };

      #############################################################
      ## Packages, fonts, env
      #############################################################

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.vim
        pkgs.nerd-fonts.jetbrains-mono
      ];

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      #############################################################
      ## Keyboard (F-keys, fast repeat, Caps -> Escape)
      #############################################################

      # Remap Caps Lock -> Escape (great for vim/neovim).
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      #############################################################
      ## macOS system defaults
      #############################################################

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

        # ---- Appearance / interface ----
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
        NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
        # Snappier window resizing (e.g. when splitting in apps).
        NSGlobalDomain.NSWindowResizeTime = 0.001;
        # Spring-loaded folders open instantly on drag-hover.
        NSGlobalDomain."com.apple.springing.enabled" = true;
        NSGlobalDomain."com.apple.springing.delay" = 0.0;

        # ---- Keyboard ----
        # F1–F10 act as standard function keys (not brightness/volume).
        NSGlobalDomain."com.apple.keyboard.fnState" = true;
        # Full keyboard access: Tab moves focus between all controls.
        NSGlobalDomain.AppleKeyboardUIMode = 3;
        # Fast key repeat (lower = faster). KeyRepeat=1 is the fastest tier;
        NSGlobalDomain.InitialKeyRepeat = 10;
        NSGlobalDomain.KeyRepeat = 2;

        # Disable auto-correction / smart substitutions
        NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
        NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
        NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
        NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;

        # ---- Window manager / Stage Manager ----
        WindowManager.AutoHide = true;
        WindowManager.EnableStandardClickToShowDesktop = false;

        controlcenter.BatteryShowPercentage = true;

        # ---- Dock ----
        dock.autohide = false;
        #dock.autohide-delay = 0.0;
        #dock.autohide-time-modifier = 0.2;
        dock.launchanim = false;
        dock.expose-animation-duration = 0.1;
        dock.mineffect = "scale";
        dock.minimize-to-application = true;
        dock.show-process-indicators = true;
        dock.mru-spaces = false;
        dock.persistent-apps = [];
        dock.persistent-others = [];
        dock.show-recents = false;
        dock.wvous-bl-corner = 1;
        dock.wvous-br-corner = 1;
        dock.wvous-tl-corner = 1;
        dock.wvous-tr-corner = 1;
        dock.tilesize = 48;

        # ---- Finder ----
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
        finder.QuitMenuItem = true;  # allow ⌘Q to quit Finder

        # ---- Misc ----
        hitoolbox.AppleFnUsageType = "Do Nothing";
        menuExtraClock.Show24Hour = true;

        trackpad.Clicking = true;
        trackpad.TrackpadThreeFingerDrag = true;

        # Spaces stay per-display (don't span all monitors).
        spaces.spans-displays = false;

        screencapture.location = "~/Pictures/Screenshots";
        screencapture.type = "png";
        screencapture.disable-shadow = true;
        screensaver.askForPasswordDelay = 0;

        loginwindow.GuestEnabled = false;

        LaunchServices.LSQuarantine = false;
        universalaccess.reduceMotion = true;
      };

      system.startup.chime = false;

      #############################################################
      ## Homebrew (casks, brews, mas)
      #############################################################

      homebrew = {
        enable = true;
        # Keep Homebrew in sync with this list on rebuild.
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "none";
        };
        casks = [
          "ghostty"
          "raycast"
        ];
        brews = [
          # shells
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
          # Xcode = 497799835;
          WeChat = 836500024;
        };
      };

      #############################################################
      ## Networking
      #############################################################

      networking.localHostName = "hxyulin-mac";
      networking.knownNetworkServices = [ "Wi-Fi" ];

      networking.applicationFirewall.enable = true;
      networking.applicationFirewall.enableStealthMode = true;

      #############################################################
      ## Power & security
      #############################################################

      power.sleep = {
        computer = 60;
        display = 30;
      };

      # Touch ID for sudo (survives across terminal sessions / tmux).
      security.pam.services.sudo_local.reattach = true;
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild switch --flake .#hxyulin-mac
    darwinConfigurations."hxyulin-mac" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ configuration ];
    };
  };
}
