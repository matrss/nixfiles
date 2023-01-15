{
  zramSwap.enable = true;
  networking.hostName = "hazuno";
  networking.domain = "m.0px.xyz";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgAt4vG44X0LcB5Xcxzhx+Yxug7z5QbD7YRjKONBTVn Matthias Riße"
  ];

  sops.defaultSopsFile = ../../secrets/hazuno/secrets.yaml;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
