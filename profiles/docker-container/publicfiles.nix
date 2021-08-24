{
  virtualisation.oci-containers.containers.publicfiles = {
    image = "caddy:2.3.0";

    volumes = [ "/home/matrss/public:/publicfiles:ro" ];

    cmd = [ "caddy" "file-server" "--browse" "--root" "/publicfiles" ];

    extraOptions = [
      "--net=services"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.publicfiles.rule=Host(`public.ara.matrss.de`)"
      "--label=traefik.http.routers.publicfiles.entrypoints=websecure"
      "--label=traefik.http.routers.publicfiles.middlewares=public@file"
    ];
  };
}
