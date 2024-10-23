{pkgs, ...}: {
  services.unifi = {
    enable = true;
    openFirewall = true;

    unifiPackage = pkgs.unifi8;
    mongodbPackage = pkgs.mongodb-7_0;
  };
}
