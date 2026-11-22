{
  description = "Lars' nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
  }:
  let

    username = "lars";

    configuration = { pkgs, ... }: {
      
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix search nixpkgs wget
      environment.systemPackages = [
        pkgs.alejandra
        pkgs.anki-bin
        pkgs.asciiquarium
        pkgs.ast-grep
        pkgs.bat
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
        pkgs.neovim
        pkgs.nixd
        pkgs.nixfmt
        pkgs.ripgrep
        pkgs.signal-desktop
        pkgs.statix
        pkgs.thunderbird
        pkgs.tig
        pkgs.uv
        pkgs.yt-dlp
      ];

      # if a package isn't available through nix, use homebrew
      homebrew = {
        enable = true;

        onActivation = {
          autoUpdate = false; #true;
          upgrade = false; #true;
          cleanup = "none"; #"uninstall";
          # Homebrew Bundle now requires explicit confirmation for --cleanup.
          #extraFlags = ["--force-cleanup"];
        };

        #brews = [
        #];

        casks = [
          "balenaetcher"
          "discord"
        ];
	
	#taps = [
	#];

        #masApps = {
        #};
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Add Nix's fish to /etc/shells so chsh accepts it.
      environment.shells = [ pkgs.fish ];

      system = {
        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 6;

        primaryUser = username;
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
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
