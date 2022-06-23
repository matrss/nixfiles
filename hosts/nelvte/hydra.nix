{
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.matrss.de";
    notificationSender = "";
    buildMachinesFiles = [];
    useSubstitutes = true;
    listenHost = "localhost";
  };

  services.nginx.virtualHosts."hydra.matrss.de" = {
    forceSSL = true;
    useACMEHost = "nelvte.matrss.de";
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
    };
  };
}
