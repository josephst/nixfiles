_: {
  programs.eza = {
    enable = true;
    enableNushellIntegration = false;
    git = true;
    icons = "auto";
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
}
