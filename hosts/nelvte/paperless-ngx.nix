{ config, ... }:

{
  sops.secrets."paperless/admin-password" = {
    owner = config.users.users.paperless.name;
    group = config.users.users.paperless.group;
  };

  sops.secrets."paperless/secret-env" = {
    owner = config.users.users.paperless.name;
    group = config.users.users.paperless.group;
  };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."paperless/admin-password".path;
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_URL = "edms.matrss.de";
    };
  };

  systemd.services.paperless-consumer.serviceConfig.EnvironmentFile = config.sops.secrets."paperless/secret-env".path;
  systemd.services.paperless-scheduler.serviceConfig.EnvironmentFile = config.sops.secrets."paperless/secret-env".path;
  systemd.services.paperless-web.serviceConfig.EnvironmentFile = config.sops.secrets."paperless/secret-env".path;

  services.nginx.virtualHosts."edms.matrss.de" = {
    forceSSL = true;
    useACMEHost = "nelvte.matrss.de";
    locations."/verify" = {
      proxyPass = "http://127.0.0.1:9091/api/verify";
      extraConfig = ''
        internal;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
      '';
    };
    locations."/" = {
      proxyPass = "http://127.0.0.1:28981";
      proxyWebsockets = true;
    };
    extraConfig = ''
      auth_request /verify;
      auth_request_set $target_url $scheme://$http_host$request_uri;
      auth_request_set $user $upstream_http_remote_user;
      auth_request_set $groups $upstream_http_remote_groups;
      auth_request_set $name $upstream_http_remote_name;
      auth_request_set $email $upstream_http_remote_email;
      proxy_set_header Remote-User $user;
      proxy_set_header Remote-Groups $groups;
      proxy_set_header Remote-Name $name;
      proxy_set_header Remote-Email $email;
      error_page 401 =302 https://idp.matrss.de/?rd=$target_url;
    '';
  };

  systemd.services.before-restic-backups-local-backup.preStart = ''
    systemctl stop paperless-consumer.service
    systemctl stop paperless-scheduler.service
    systemctl stop paperless-web.service
  '';

  systemd.services.after-restic-backups-local-backup.postStart = ''
    systemctl start paperless-consumer.service
    systemctl start paperless-scheduler.service
    systemctl start paperless-web.service
  '';
}
