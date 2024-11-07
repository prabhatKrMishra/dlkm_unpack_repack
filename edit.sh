#!/bin/bash

if [[ "$1" == "unpack" ]]; then
    IMGFILE="$2"
    if [[ -z "$IMGFILE" ]]; then
        echo "[ERROR] No image file specified."
        exit 1
    fi
    PARTITION=$(basename "$IMGFILE" .img)
else
    if [ -d temp_* ]; then
        PARTITION=$(ls -d temp_* | sed 's/temp_//')
        IMGFILE="$PARTITION.img"
    else
        echo "[ERROR] No temp partition directory found. Please run unpack first."
        exit 1
    fi
fi

NEWIMAGE="$PARTITION-new.img"
LOCALDIR=$(pwd)
MOUNTDIR="$LOCALDIR/$PARTITION"
TEMPDIR="$LOCALDIR/temp_$PARTITION"
toolsdir="$LOCALDIR/tools"
tmpdir="$LOCALDIR/tmp"
fileconts="$tmpdir/plat_file_contexts"

usage() {
    echo "Usage: sudo ./$0 <unpack path_to_partition.img | repack>"
}

contextfix() {
    mkdir -p "$(dirname "$fileconts")"
    echo "/($PARTITION|vendor/$PARTITION|system/vendor/$PARTITION)(/.*)?         u:object_r:vendor_file:s0" > "$fileconts"
    echo "/($PARTITION|vendor/$PARTITION|system/vendor/$PARTITION)/etc(/.*)?     u:object_r:vendor_configs_file:s0" >> "$fileconts"
}

unpack() {
    mkdir -p "$MOUNTDIR" "$TEMPDIR" "$tmpdir"
    echo "[INFO] Unpacking $PARTITION image..."

    if ! sudo mount -o loop "$IMGFILE" "$MOUNTDIR"; then
        echo "[ERROR] Failed to mount the EROFS image."
        exit 1
    fi

    sudo cp -a "$MOUNTDIR/." "$TEMPDIR/"
    sudo chmod -R 777 "$TEMPDIR"

    sudo umount "$MOUNTDIR"

    echo "[INFO] Image unpacked to $TEMPDIR for editing."
}

rebuild() {
    echo "[INFO] Rebuilding $PARTITION as EROFS image..."

    contextfix

    sudo chmod -R 777 "$TEMPDIR"

    mkfs.erofs "$NEWIMAGE" "$TEMPDIR" --file-contexts="$fileconts"

    echo "[INFO] Done"
}

clean_up() {
    [[ -d "$MOUNTDIR" && "$MOUNTDIR" != "/" ]] && sudo rm -rf "$MOUNTDIR"
    [[ -d "$TEMPDIR" && "$TEMPDIR" != "/" ]] && sudo rm -rf "$TEMPDIR"
    [[ -d "$tmpdir" && "$tmpdir" != "/" ]] && sudo rm -rf "$tmpdir"
    echo "[INFO] Clean up complete"
}

if [[ "$1" == "unpack" ]]; then
    unpack
elif [[ "$1" == "repack" ]]; then
    rebuild
    trap clean_up EXIT
else
    usage
    exit 1
fi

