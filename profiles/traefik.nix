{ lib, config, pkgs, ... }:

{
  services.traefik = {
    enable = true;
    group = "docker";
    dataDir = "/volumes/traefik-data";

    staticConfigOptions = {
      global.sendAnonymousUsage = false;
      log.level = "warn";
      api.dashboard = true;
      accessLog = {
        filePath = "${config.services.traefik.dataDir}/access.log";
        bufferingSize = 100;
        filters.statusCodes = "400-499";
      };
      entryPoints.web = {
        address = ":80";
        http.redirections.entrypoint = {
          to = "websecure";
          scheme = "https";
        };
      };
      entryPoints.websecure = {
        address = ":443";
        http.tls.certresolver = "letsencrypt";
      };
      providers.docker = {
        exposedByDefault = false;
        network = "web";
      };
      certificatesResolvers.letsencrypt.acme = {
        email = "matthias.risze@gmail.com";
        storage = "${config.services.traefik.dataDir}/letsencrypt-acme.json";
        httpChallenge.entryPoint = "web";
      };
    };

    dynamicConfigOptions = {
      tls.options.default = {
        minVersion = "VersionTLS12";
        sniStrict = true;
        cipherSuites = [
          "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
          "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
          "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
        ];
      };
      tls.options.mintls13 = {
        minVersion = "VersionTLS13";
        sniStrict = true;
      };

      http.middlewares =
        let
          secureHeadersWith = overwrites: lib.recursiveUpdate
            {
              accessControlAllowMethods = [ "GET" "OPTIONS" "PUT" ];
              accessControlMaxAge = 100;
              hostsProxyHeaders = [ "X-Forwarded-Host" ];
              stsSeconds = 63072000;
              stsIncludeSubdomains = true;
              stsPreload = true;
              forceSTSHeader = true;
              frameDeny = true;
              contentTypeNosniff = true;
              browserXssFilter = true;
              referrerPolicy = "same-origin";
              permissionsPolicy = "camera 'none'; geolocation 'none'; microphone 'none'; payment 'none'; usb 'none'; vr 'none';";
              customResponseHeaders = {
                X-Robots-Tag = "none";
              };
            }
            overwrites;
        in
        {
          public.chain.middlewares = [ "rate-limit" "secure-headers" ];
          public_style-src-unsafe-inline.chain.middlewares = [ "rate-limit" "secure-headers_style-src-unsafe-inline" ];
          public_no-csp.chain.middlewares = [ "rate-limit" "secure-headers_no-csp" ];
          secured.chain.middlewares = [ "rate-limit" "secure-headers" "authelia" ];
          secured_style-src-unsafe-inline.chain.middlewares = [ "rate-limit" "secure-headers_style-src-unsafe-inline" "authelia" ];
          secured_no-csp.chain.middlewares = [ "rate-limit" "secure-headers_no-csp" "authelia" ];
          rate-limit.rateLimit = {
            average = 100;
            period = "1s";
            burst = 50;
          };
          authelia.forwardAuth = {
            address = "http://127.0.0.1:9091/api/verify?rd=https://auth.ara.matrss.de/";
            trustForwardHeader = true;
            authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
          };
          # src: https://www.reddit.com/r/selfhosted/comments/iqvykv/authelia_and_multiple_apps/g5yds86/
          secure-headers.headers = secureHeadersWith {
            contentSecurityPolicy = "upgrade-insecure-requests; default-src 'none'; frame-ancestors 'self'; object-src 'none'; require-sri-for script style; base-uri 'self'; form-action 'self'; manifest-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; media-src 'self' blob: data:; worker-src 'self' blob:; font-src 'self'; connect-src 'self' wss:;";
          };
          secure-headers_style-src-unsafe-inline.headers = secureHeadersWith {
            contentSecurityPolicy = "upgrade-insecure-requests; default-src 'none'; frame-ancestors 'self'; object-src 'none'; require-sri-for script style; base-uri 'self'; form-action 'self'; manifest-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; media-src 'self' blob: data:; worker-src 'self' blob:; font-src 'self'; connect-src 'self' wss:;";
          };
          secure-headers_no-csp.headers = secureHeadersWith {
            customResponseHeaders = {
              X-Frame-Options = "SAMEORIGIN";
            };
          };
        };

      http.routers.traefik = {
        rule = "Host(`traefik.ara.matrss.de`)";
        entryPoints = [ "websecure" ];
        middlewares = [ "secured" ];
        service = "api@internal";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Network for docker containers
  systemd.services.init-web-network = {
    description = "Create a network bridge named web for exposed services.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig =
      let executable =
        if config.virtualisation.oci-containers.backend == "docker" then "${config.virtualisation.docker.package}/bin/docker"
        else if config.virtualisation.oci-containers.backend == "podman" then "${config.virtualisation.podman.package}/bin/podman"
        else throw "Unhandled backend: ${config.virtualisation.oci-containers.backend}";
      in
      {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${pkgs.bash}/bin/sh -c "${executable} network create --driver bridge web || true"
        '';
        ExecStop = ''
          ${pkgs.bash}/bin/sh -c "${executable} network rm web || true"
        '';
      };
  };
}
