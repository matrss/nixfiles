{
  imports = [ ./protonvpn.nix ];

  virtualisation.oci-containers.containers.cr-unblocker = {
    image = "onestay/cr-unblocker-server:latest";

    dependsOn = [ "protonvpn" ];

    ports = [ "3001:3001" ];
  };
}
