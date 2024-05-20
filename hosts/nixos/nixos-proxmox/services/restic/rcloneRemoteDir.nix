{
  age.secrets.rcloneRemoteDir = {
    file = ../../secrets/rcloneRemote.age;
    owner = "restic";
  };

  # contains single line with value of $RESTIC_REPOSITORY (such as rclone:b2:foo/bar)
  age.secrets.b2WithRclone = {
    file = ../../secrets/restic/b2WithRclone.age;
    owner = "restic";
  };
}
