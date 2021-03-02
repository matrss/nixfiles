{ hosts, ... }:

{
  services.tinc.networks.mesh = {
    hosts = {
      andromeda = ''
        Subnet = ${hosts.andromeda.ip.tinc}

        ${builtins.readFile ../secrets/hosts/andromeda/tinc/ed25519_key.pub}
        ${builtins.readFile ../secrets/hosts/andromeda/tinc/rsa_key.pub}
      '';
      draco = ''
        Address = ${hosts.draco.ip.public}
        Subnet = ${hosts.draco.ip.tinc}

        ${builtins.readFile ../secrets/hosts/draco/tinc/ed25519_key.pub}
        ${builtins.readFile ../secrets/hosts/draco/tinc/rsa_key.pub}
      '';
      ara = ''
        Subnet = ${hosts.ara.ip.tinc}

        ${builtins.readFile ../secrets/hosts/ara/tinc/ed25519_key.pub}
        ${builtins.readFile ../secrets/hosts/ara/tinc/rsa_key.pub}
      '';
      vela = ''
        Subnet = ${hosts.vela.ip.tinc}
        Port = 2000

        ${builtins.readFile ../secrets/hosts/vela/tinc/ed25519_key.pub}
        ${builtins.readFile ../secrets/hosts/vela/tinc/rsa_key.pub}
      '';
    };
  };
}
