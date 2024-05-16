{
  # common
  myconfig = import ../common/myconfig.nix;

  # nixos specific
  rcloneCopy = import ./rclone-to-b2.nix;
  open-webui = import ./open-webui.nix;
}
