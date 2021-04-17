{ pkgs, ... }:

{
  ara-remote-unlock = pkgs.writeScriptBin "ara-remote-unlock" ''
    #! /bin/sh

    ${pkgs.openssh}/bin/ssh -p 2222 root@192.168.178.254 'sh -c "cryptsetup-askpass"'
  '';
  nm-connection-sync = pkgs.writeScriptBin "nm-connection-sync" ''
    if [ -z "$NIX_FLAKE_DIR" ]; then
        printf "ERROR: NIX_FLAKE_DIR not set\n" >&2
        exit 1
    fi
    conn_file="$NIX_FLAKE_DIR"/secrets/nm-connections.tar
    system_conn_dir=/etc/NetworkManager/system-connections
    tmp_dir="$(mktemp -d)"

    # Extract connection files from repo
    [ -f "$conn_file" ] && ${pkgs.gnutar}/bin/tar --extract -f "$conn_file" --directory "$tmp_dir"
    # Update with connections present on the system
    [ -d "$system_conn_dir" ] && sudo -E ${pkgs.rsync}/bin/rsync -av "$system_conn_dir"/ "$tmp_dir"
    # Create updated archive
    sudo -E ${pkgs.gnutar}/bin/tar --create -f "$conn_file" --directory "$tmp_dir" .
    # Update ownership of archive
    sudo -E chown "$USER:$(id -g -n $USER)" "$conn_file"
    # Update connection files on system
    sudo -E ${pkgs.rsync}/bin/rsync -av "$tmp_dir"/ "$system_conn_dir"

    sudo -E rm -r "$tmp_dir"
  '';
  scan = pkgs.writeScriptBin "scan" ''
    #! /bin/sh

    if [ $# -lt 2 ]; then
        echo Missing arguments
        exit 1
    fi

    scanner=$(scanimage -L | sed -e "s/[^\`]*\`\([^\']*\).*/\1/g" | grep Samsung)
    source="$1"

    if [ "$2" = "batch" ]; then
        batch_start="$3"
            batch_increment="$4"
        filename="$5-%d.png"
        ${pkgs.sane-backends}/bin/scanimage --device "$scanner" --resolution 300 --source "$source" --format=png --mode Color --batch="$filename" --batch-start "$batch_start" --batch-increment "$batch_increment"
    else
        filename="$2.png"
        ${pkgs.sane-backends}/bin/scanimage --device "$scanner" --resolution 300 --source "$source" --format=png --mode Color > "$filename"
    fi

    # ${pkgs.sane-backends}/bin/scanimage --device "$SCANNER" --resolution 300 --source <Flatbed/ADF> [--batch <filename>%d.png] --format=png --mode Color -l 0 -t 0 -x 210 -y 297
  '';
  scan2pdf = pkgs.writeScriptBin "scan2pdf" ''
    #! /bin/sh

    out="$1"
    shift

    temp_file=$(mktemp)
    for f in $@; do
        echo "$f" >> "$temp_file"
    done

    ${pkgs.tesseract4}/bin/tesseract -l deu "$temp_file" "$out" pdf

    rm $temp_file
  '';
}
