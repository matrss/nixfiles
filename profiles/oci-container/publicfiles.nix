{
  virtualisation.oci-containers.containers.publicfiles = {
    image = "caddy:2.4.6";

    volumes = [ "/home/matrss/public:/publicfiles:ro" ];

    cmd = [ "caddy" "file-server" "--browse" "--root" "/publicfiles" ];

    extraOptions = [
      "--network=web"
      "--label=traefik.enable=true"
      "--label=traefik.http.routers.publicfiles.rule=Host(`public.ara.matrss.de`)"
      "--label=traefik.http.routers.publicfiles.entrypoints=websecure"
      "--label=traefik.http.routers.publicfiles.middlewares=public_style-src-unsafe-inline@file"
    ];
  };
}
