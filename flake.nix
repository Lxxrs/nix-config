{
  description = "Lars' nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      username = "lars";

      configuration = { pkgs, ... }: {
        # Add Nix's fish to /etc/shells so chsh accepts it.
        environment.shells = [ pkgs.fish ];

        # List packages installed in system profile. To search by name, run:
        # $ nix search nixpkgs wget
        environment.systemPackages = [
          #pkgs.alsa-scarlett-gui # Linux only
          pkgs.anki-bin
          pkgs.asciiquarium
          pkgs.ast-grep
          pkgs.bat
          pkgs.btop
          pkgs.cargo
          pkgs.claude-code
          pkgs.deadnix
          pkgs.discord
          pkgs.element-desktop
          pkgs.fastfetch
          pkgs.fd
          pkgs.fzf
          pkgs.ghostty-bin # macOS
          pkgs.git
          pkgs.git-cliff
          pkgs.git-filter-repo
          pkgs.kubectx
          pkgs.k9s
          pkgs.localsend
          pkgs.neovim
          pkgs.nixd
          pkgs.nixfmt-tree
          pkgs.opentofu
          pkgs.ripgrep
          pkgs.signal-desktop
          pkgs.statix
          pkgs.thunderbird
          pkgs.tig
          pkgs.uv
          pkgs.wget
          pkgs.yt-dlp
        ];

        fonts.packages = [
          pkgs.nerd-fonts.jetbrains-mono
        ];

        # if a package isn't available through nix, use homebrew
        homebrew = {
          enable = true;

          onActivation = {
            autoUpdate = true;
            upgrade = true;
            cleanup = "none"; # "uninstall|zap";
            # Homebrew Bundle now requires explicit confirmation for --cleanup.
            #extraFlags = ["--force-cleanup"];
          };

          enableFishIntegration = true;

          # Formulae to install
          brews = [
            "astro"
            "anomalyco/tap/opencode-v2"
            "container"
            "go"
            "kubernetes-cli"
            "lazygit"
            "lua"
            "lua-language-server"
            "luarocks"
            "minikube"
            "mole"
            "mtr"
            "nmap"
            "pnpm"
            "starship"
            "typst"
          ];

          casks = [
            "actual"
            "balenaetcher"
            "bitwarden"
            "claude"
            "ente-auth"
            "firefox"
            "focusrite-control-2"
            "helium-browser"
            "mullvad-browser"
            "mullvad-vpn"
            "obsidian"
            "orbstack"
            "raspberry-pi-imager"
            "tor-browser"
            "vivaldi"
            "vscodium"
            "zen"
          ];

          #taps = [
          #];

          masApps = {
            "Home Assistant" = 1099568401;
            "Keynote: Design Presentations" = 361285480;
            #"Manet Music" = 6470928235;
            "Numbers: Make Spreadsheets" = 361304891;
            "Pages: Create Documents" = 361309726;
            "uBlock Origin Lite" = 6745342698;
            "WireGuard" = 1451685025;
          };
        };

        # Automatic cleanup using garbage collection
        nix.gc.automatic = true;
        nix.gc.options = "--delete-older-than 10d";
	nix.optimise.automatic = true;   # macOS
        #nix.settings.auto-optimise-store = true; # Linux

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        nixpkgs.config.allowUnfree = true;

        # Enable alternative shell support in nix-darwin.
        programs.fish.enable = true;

        system = {
          # Set Git commit hash for darwin-version.
          configurationRevision = self.rev or self.dirtyRev or null;

          primaryUser = username;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          stateVersion = 6;
        };
      };
    in
    {
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      # MacBook - Build darwin flake using:
      # $ darwin-rebuild build --flake ~/nix-config#m3-air
      darwinConfigurations."m3-air" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
        ];
      };

      # ThinkPad - Build nixOS flake using:
      # sudo nixos-rebuild switch --flake ~/nix-config#t480
      nixosConfigurations."t480" = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/t480/configuration.nix
        ];
      };
    };
}
