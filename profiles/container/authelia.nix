{
  virtualisation.oci-containers.containers.authelia = {
    image = "authelia/authelia";

    volumes = [
      "${../../secrets/hosts/ara/authelia/configuration.yml}:/configuration.yml:ro"
      "/volumes/authelia-config:/config:rw"
    ];

    cmd = [
      "--config" "/configuration.yml"
    ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.authelia.rule=Host(`auth.ara.matrss.de`)"
      "--label=traefik.http.routers.authelia.entrypoints=websecure"
      "--label=traefik.http.middlewares.authelia.forwardauth.address=http://authelia:9091/api/verify?rd=https://auth.ara.matrss.de/"
      "--label=traefik.http.middlewares.authelia.forwardauth.trustForwardHeader=true"
      "--label=traefik.http.middlewares.authelia.forwardauth.authResponseHeaders=Remote-User, Remote-Groups, Remote-Name, Remote-Email"
      "--label=traefik.http.middlewares.authelia-basic.forwardauth.address=http://authelia:9091/api/verify?auth=basic"
      "--label=traefik.http.middlewares.authelia-basic.forwardauth.trustForwardHeader=true"
      "--label=traefik.http.middlewares.authelia-basic.forwardauth.authResponseHeaders=Remote-User, Remote-Groups, Remote-Name, Remote-Email"
    ];
  };
}
