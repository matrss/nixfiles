{
  ara-remote-unlock = { writeShellScriptBin, openssh }: writeShellScriptBin "ara-remote-unlock" ''
    ${openssh}/bin/ssh -p 2222 root@192.168.178.254 'sh -c "cryptsetup-askpass"'
  '';

  nm-connection-sync = { writeShellScriptBin, gnutar, rsync }: writeShellScriptBin "nm-connection-sync" ''
    if [ -z "$PRJ_ROOT" ]; then
        printf "ERROR: PRJ_ROOT not set\n" >&2
        exit 1
    fi
    conn_file="$PRJ_ROOT"/secrets/nm-connections.tar
    system_conn_dir=/etc/NetworkManager/system-connections
    tmp_dir="$(mktemp -d)"

    # Extract connection files from repo
    [ -f "$conn_file" ] && ${gnutar}/bin/tar --extract -f "$conn_file" --directory "$tmp_dir"
    # Update with connections present on the system
    [ -d "$system_conn_dir" ] && sudo -E ${rsync}/bin/rsync -av "$system_conn_dir"/ "$tmp_dir"
    # Create updated archive
    sudo -E ${gnutar}/bin/tar --create -f "$conn_file" --directory "$tmp_dir" .
    # Update ownership of archive
    sudo -E chown "$USER:$(id -g -n $USER)" "$conn_file"
    # Update connection files on system
    sudo -E ${rsync}/bin/rsync -av "$tmp_dir"/ "$system_conn_dir"

    sudo -E rm -r "$tmp_dir"
  '';

  generate-hostname = { writeShellScriptBin, python3 }: writeShellScriptBin "generate-hostname" ''
    ${python3}/bin/python3 \
      -c 'import string; import random; print("".join(random.choices(string.ascii_lowercase, k=6)))'
  '';
}
