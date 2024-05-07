# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... } @inputs :
let
  emacs-pkg = ((pkgs.emacsPackagesFor pkgs.emacs-unstable).emacsWithPackages (epkgs: [ epkgs.vterm ]));
in
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable the I3 window manager
  services.xserver.windowManager.i3 = {
    enable = true;
    extraSessionCommands = ''
      xrandr --output Virtual1 --mode 1920x1080
    '';
  };
  services.xserver.displayManager.defaultSession = "none+i3";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shidou = {
    isNormalUser = true;
    description = "Shidou";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
      vim
      google-chrome
      #  thunderbird
    ];
  };


  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "shidou";

  # Enable guest additions for VirtualBox instance.
  virtualisation.virtualbox.guest.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ranger
    ## Emacs itself
    binutils # native-comp needs 'as', provided by this
    # 28.2 + native-comp
    emacs-pkg

    ## Doom dependencies
    git
    (ripgrep.override { withPCRE2 = true; })
    gnutls # for TLS connectivity

    ## Optional dependencies
    fd # faster projectile indexing
    imagemagick # for image-dired
    pinentry-emacs # in-emacs gnupg prompts
    zstd # for undo-fu-session/undo-tree compression
    clang-tools

    ## Module dependencies
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :tools editorconfig
    editorconfig-core-c # per-project style config
    # :tools lookup & :lang org +roam
    sqlite
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
    # :lang beancount
    beancount
    #unstable.fava  # HACK Momentarily broken on nixos-unstable
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Enable Git
  programs.git.enable = true;

  # Set aliases for bash shell
  programs.bash.shellAliases = {
    config = "sudo vim /etc/nixos/configuration.nix";
    home = "vim /home/shidou/flake/home.nix";
    nb = "sudo nixos-rebuild build";
    nt = "sudo nixos-rebuild test";
    ns = "sudo nixos-rebuild switch";
  };

  # Invert capslock and escape for vim use. (I'm slowly going mad without it)
  services.xserver.xkbOptions = caps:escape_shifted_capslock;
  console.useXkbConfig = true;

  # Set wheel as not needing sudo password
  security.sudo.wheelNeedsPassword = false;

  nix = {
    # Set flakes and nix command 
    extraOptions = ''
      	experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      trusted-users = [ "root" "shidou" ];
      auto-optimise-store = true;
      substituters = [
        "https://nix-gaming.cachix.org"
        "https://nixpkgs.cachix.org"
      ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      ];
    };
  };
  # Emacs Macumba
  nixpkgs.overlays = [ inputs.emacs-overlay.overlay ];

  environment = {
    extraInit = ''
      export PATH="/home/shidou/.emacs.d/bin:${emacs-pkg}/emacs/bin:$PATH"
    '';
  };

  fileSystems = {
    "/home/shidou/.doom.d" = {
      device = "/home/shidou/flake/doom.d";
      options = [ "bind" ];
      depends = [ "/" ];
    };
  };

  #modules.shell.zsh.rcFiles = [ "${configDir}/emacs/aliases.zsh" ];

  fonts.packages = [ pkgs.emacs-all-the-icons-fonts ];

  system.userActivationScripts = {
    installDoomEmacs = {
      text = ''
        if [ ! -d "/home/shidou/.emacs.d" ]; then
           ${pkgs.git}/bin/git clone --depth=1 --single-branch "https://github.com/doomemacs/doomemacs" "/home/shidou/.emacs.d"
        fi
        EMACS="${emacs-pkg}/bin/emacs" PATH="${pkgs.git}/bin:${pkgs.bash}/bin:$PATH" /home/shidou/.emacs.d/bin/doom sync
      '';
    };
  };
  # FIM DA MACUMBA DO EMACS
}
