{ config, ... }:

{
  services.grafana = {
    enable = true;
    settings.server.http_addr = "127.0.0.1";
    settings.server.http_port = 9999;
  };

  services.nginx.virtualHosts."status.0px.xyz" = {
    forceSSL = true;
    useACMEHost = "nelvte.m.0px.xyz";
    locations."/" = {
      proxyPass = "http://127.0.0.1:9999";
      proxyWebsockets = true;
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9000;
    retentionTime = "100y";

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];

    exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" "processes" ];
      listenAddress = "127.0.0.1";
      port = 9001;
    };
  };

  services.loki = {
    enable = true;

    configuration = {
      auth_enabled = false;
      analytics.reporting_enabled = false;

      server = {
        http_listen_port = 10000;
        grpc_listen_port = 10001;
      };

      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/var/lib/loki";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      schema_config = {
        configs = [{
          from = "2022-11-23";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 10002;
        grpc_listen_port = 0;
      };

      positions.filename = "/tmp/positions.yaml";

      clients = [{
        url = "http://127.0.0.1:10000/loki/api/v1/push";
      }];

      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels.job = "systemd-journal";
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
  };
}
