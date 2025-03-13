# Better defaults for OpenSSH
{ lib, isLaptop, ... }:
{
  services.openssh = {
    enable = true;
    # Don't open the firewall on for SSH on laptops; Tailscale will handle it.
    openFirewall = !isLaptop;

    settings = {
      X11Forwarding = false;
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkDefault "prohibit-password";
      UseDns = false;
      # unbind gnupg sockets if they exists
      StreamLocalBindUnlink = true;

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
}
