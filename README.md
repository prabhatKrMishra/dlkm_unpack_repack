# Trident dlkm Unpacker/Repacker
## (erofs) only!

## Prerequisites ###
- Linux running kernel 5.4 or up
- Internet and a **Working Mind**

## How to use ###

### Install required library
```
sudo apt-get install erofs-utils
```

### Clone this repo

```
git clone https://github.com/prabhatKrMishra/dlkm_unpack_repack.git

cd dlkm_unpack_repack
```

### Copy dlkm image (erofs only)
```
cp /path/to/img/vendor_dlkm.img vendor_dlkm.img
```

### Run unpack
```
bash edit.sh unpack vendor_dlkm.img
```

Now modify your partition content located inside **temp_vendor_dlkm** folder

### Run repack
```
bash edit.sh repack
```

Output will give **vendor_dlkm-new.img**

### You can flash vendor_dlkm-new.img to your device now.
```
adb reboot fastboot

fastboot flash vendor_dlkm ./vendor_dlkm-new.img
```

Hit the star button if you liked my work !
