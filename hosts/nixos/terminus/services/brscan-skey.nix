{ pkgs, ... }:
{
  # AirScan handles normal driverless scanning. The proprietary scan-key
  # daemon uses brscan5's network-device registry to subscribe to button
  # events from the scanner.
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    brscan5 = {
      enable = true;
      netDevices.Brother_DCP_L2647DW = {
        model = "DCP-L2647DW";
        nodename = "BRW44F79FE0D797";
      };
    };
  };

  services.brscan-skey = {
    enable = true;
    scanDirectory = "/storage/homes/public/scans";
    scanFileUmask = "0022";
  };
}
