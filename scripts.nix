{ pkgs, ... }:

{
  ara-deploy-early-boot-ssh-host-key = pkgs.writeScriptBin "ara-deploy-early-boot-ssh-host-key" ''
    #! /bin/sh

    ${pkgs.openssh}/bin/scp secrets/hosts/ara/initrd_ssh/host_ed25519_key.priv root@ara.matrss.de:~
  '';
  ara-remote-unlock = pkgs.writeScriptBin "ara-remote-unlock" ''
    #! /bin/sh

    ${pkgs.openssh}/bin/ssh -p 2222 root@192.168.178.254 'sh -c "cryptsetup-askpass"'
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