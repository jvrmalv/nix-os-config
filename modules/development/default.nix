{ config, pkgs, lib, ... }:
let
  cfg = config.development;
  conditional-lang = x: y: if builtins.elem x cfg.languages then y else [ ];
  languages = with pkgs; (
    [
      mu
      python39Packages.nose
      python3Full
      ripgrep
      cmigemo
      black
      nushell
      du-dust
      dbeaver
      vim
      gnumake
      libtool
      libvterm
      nixpkgs-fmt
      shellcheck
      shfmt
      wireguard-tools
      racket
      podman-compose
      cmake
      gdb
      gf
      gcc
      jq
      fd
      xdelta
      fasm
      raylib
    ]
    ++ (conditional-lang "dotnet" [
      dotnet-sdk
    ])
    ++ (conditional-lang "crystal" [
      icr
    ])
    ++ (conditional-lang "f#" [
      fsharp
      dotnet-sdk
    ])
    ++ (conditional-lang "ocaml" [
      ocamlPackages.utop
    ])
    ++ (conditional-lang "elm" [
      elmPackages.elm
      elmPackages.elm-format
      elmPackages.create-elm-app
      elmPackages.elm-language-server
    ])
    ++ (conditional-lang "elixir" [
      elixir_1_15
      inotify-tools
    ])
    ++ (conditional-lang "web" [
      yarn
      chromedriver
    ])
    ++ (conditional-lang "zig" [
      zig
    ])
    ++ (conditional-lang "node" [
      nodejs
      nodePackages.stylelint
      nodePackages.js-beautify
      yarn
    ])
    ++ (conditional-lang "ruby" [
      ruby_3_1
    ])
    ++ (conditional-lang "scala" [
      metals
    ])
    ++ (conditional-lang "haskell" [
      # Haskell Libraries
      #haskellPackages.Cabal_3_6_3_0
      #haskellPackages.brittany
      #haskellPackages.hlint
      #haskellPackages.hoogle
      #haskellPackages.nixfmt
    ])
    ++ (conditional-lang "clojure" [
      clj-kondo
    ])
    ++ (conditional-lang "rust" [
      cargo
      rustc
      rustfmt
      rust-analyzer
      rust-code-analysis
    ])
    ++ (conditional-lang "android" [
      android-studio
      android-tools
      adbfs-rootless
    ])
    ++ (conditional-lang "aws" [
      awscli
      aws-iam-authenticator
      eksctl
    ])
    ++ (conditional-lang "clasp" [
      google-clasp
    ])
    ++ (conditional-lang "oracle-cloud" [
      oci-cli
    ])
    ++ (conditional-lang "devops" [
      terraform
      ansible
    ])
    ++ (conditional-lang "kubernetes" [
      kubernetes
      (wrapHelm kubernetes-helm {
        plugins = with kubernetes-helmPlugins; [ helm-diff ];
      })
      minikube
      k9s
    ])
  );
in
{
  options.development = {
    enable = lib.mkEnableOption "Enable Development Module";
    languages = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Enabled Development modules";
    };
  };
  config = lib.mkIf cfg.enable {
    services.udev.packages = [ pkgs.android-udev-rules ];
    services.postgresql.enable = true;
    services.postgresql.package = pkgs.postgresql_14;
    services.postgresql.authentication = lib.mkForce ''
      # Generated file; do not edit!
      local all all              trust
      host  all all 192.168.0.88/32 trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128      trust
    '';
    services.postgresql.settings.listen_addresses = lib.mkForce "*";
    boot.kernelModules = [ "kvm-amd" ];
    systemd.enableUnifiedCgroupHierarchy = true;
    virtualisation.libvirtd.enable = true;
    users.extraUsers.maxhero.extraGroups = [ "libvirtd" "kvm" ];
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [ virt-manager ] ++ languages;
    virtualisation.oci-containers = {
      backend = "podman";
      /*
      containers = {
        code-server = {
          image = "codercom/code-server";
          ports = ["7654:8080"];
          volumes = [
            "/home/maxhero/projects/:/home/coder/project/"
            "/home/maxhero/.config:/home/coder/.config"
          ];
          environment = {
            PASSWORD = "code-space-666";
          };
          cmd = ["code-server --allow-http --auth password"];
        };
      };
      */
    };
    virtualisation.podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
    };

    # Make containers work properly
    systemd.services."user@".serviceConfig.Delegate = "yes";
    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    security.pam.sshAgentAuth = {
      enable = true;
      authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
    };
  };
}
