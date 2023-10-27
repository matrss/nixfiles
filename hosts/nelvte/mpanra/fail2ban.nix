{
  services.fail2ban = {
    enable = true;
    bantime = "10m";
    bantime-increment = {
      enable = true;
      overalljails = true;
      maxtime = "24h";
      rndtime = "5m";
    };
  };
}
