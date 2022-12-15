{
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 443;
    tls.letsencrypt.hostname = "meshnet.matrss.xyz";
    serverUrl = "https://meshnet.matrss.xyz";
    settings = {
      ip_prefixes = [
        "fd7a:115c:a1e0::/48"
        "100.64.0.0/10"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
