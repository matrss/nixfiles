{
  networking = {
    nameservers = [ "127.0.0.1" "::1" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      cache_min_ttl = 60;
      cache_max_ttl = 60;
      cache_neg_min_ttl = 60;
      cache_neg_max_ttl = 60;
      sources.odoh-servers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
        ];
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        cache_file = "/var/lib/dnscrypt-proxy/odoh-servers.md";
      };
      sources.odoh-relays = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
          "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
        ];
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        cache_file = "/var/lib/dnscrypt-proxy/odoh-relays.md";
      };
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];
      odoh_servers = true;
      server_names = [ "odoh-cloudflare" ];
      anonymized_dns = {
        routes = [
          {
            server_name = "odoh-cloudflare";
            via = [
              "odohrelay-ams"
              "odohrelay-crypto-sx"
              "odohrelay-se"
              "odohrelay-surf"
            ];
          }
        ];
      };
    };
  };
}
