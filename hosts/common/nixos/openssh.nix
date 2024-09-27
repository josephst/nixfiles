{config, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      # Harden
      PasswordAuthentication = false; # TODO: revisit? Maybe allow passwords?
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
      # Allow X11 forwarding on non-container images
      X11Forwarding = !config.boot.isContainer;
      # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
        "sntrup761x25519-sha512@openssh.com"
      ];
    };
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.services.sudo.sshAgentAuth = true;
  security.pam.sshAgentAuth.enable = true;
}
