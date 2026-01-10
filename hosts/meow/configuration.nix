# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  config,
  lib,
  pkgs,
  hostName,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.self.modules.nixosModules.default
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Networking
  networking.networkmanager.enable = true;
  services.netbird.enable = true;
  services.sshd.enable = true;

  age.secrets."wifi/owo" = { };
  age.secrets."wifi/red" = { };
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.age.secrets."wifi/owo".path
      config.age.secrets."wifi/red".path
    ];

    profiles = {
      owo = {
        connection = {
          id = "$OWO_SSID";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$OWO_SSID";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$OWO_PW";
        };
      };
      red = {
        connection = {
          id = "$RED_SSID";
          type = "wifi";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$RED_SSID";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$RED_PW";
        };
      };
    };
  };

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  fonts = {
    packages = with pkgs; [
      noto-fonts-color-emoji
    ];
    enableDefaultPackages = true;

    fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];
  };

  # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  age.secrets."user-password" = { };
  users.users.folf = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  }
  // (
    if config.age.ready then
      {
        hashedPasswordFile = config.age.secrets.user-password.path;
      }
    else
      { }
  );

  services.displayManager.ly.enable = true;
  programs = {
    firefox.enable = true;
    steam.enable = true;
    niri.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      histFile = "$HOME/.zsh_history";
      histSize = 10000;
      setOptions = [
        "HIST_IGNORE_ALL_DUPS"
      ];
    };
    direnv.enable = true;
  };
  virtualisation.docker = {
    enable = false;

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };
  services.pcscd.enable = true;
  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    vscode
    nixfmt-rfc-style

    xwayland-satellite
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk

    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    alacritty
    anyrun
    starship
    git
    unzip
    jetbrains.datagrip

    telegram-desktop
    signal-desktop
    tidal-hifi
    bitwarden-desktop
    (discord-canary.override {
      withEquicord = true;
    })
  ];

  # DO NOT CHANGE, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
