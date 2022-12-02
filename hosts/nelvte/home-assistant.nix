{ config, ... }:

{
  sops.secrets."home-assistant-secrets.yaml" = {
    owner = config.users.users.hass.name;
    path = "/var/lib/hass/secrets.yaml";
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
    ];
    config = {
      homeassistant = {
        external_url = "https://home.matrss.xyz";
        name = "Home";
        temperature_unit = "C";
        unit_system = "metric";
        time_zone = "Europe/Amsterdam";
      };
      frontend = { };
      http = {
        server_host = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
      default_config = { };
      met = { };
      esphome = { };
      zone = [
        {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          radius = "!secret radius";
          icon = "mdi:home";
        }
      ];
    };
  };

  services.nginx.virtualHosts."home.matrss.xyz" = {
    forceSSL = true;
    useACMEHost = "nelvte.m.matrss.xyz";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };
}
