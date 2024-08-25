#!/bin/bash

# Build an Android kernel that is actually UEFI disguised as the Kernel
cat ./BootShim/ARM/BootShim.bin "./Build/ja3gxxPkg/${_TARGET_BUILD_MODE}_CLANGDWARF/FV/JA3GXX_UEFI.fd" > "./Resources/bootpayload.bin"||exit 1

# Create a Bootable Android Boot Image
python3 ./Resources/Scripts/mkbootimg.py \
  --kernel ./Resources/bootpayload.bin \
  --ramdisk ./Resources/ramdisk \
  --base 0x10000000 \
  --kernel_offset 0x00008000 \
  --ramdisk_offset 0x01000000 \
  --second_offset 0x00f00000 \
  --tags_offset 0x00000100 \
  --os_version 6.0.0 \
  --pagesize 2048 \
  --os_patch_level "$(date '+%Y-%m')" \
  --header_version 0 \
  -o "boot.img" \
  ||_error "\nFailed to create Android Boot Image!\n"

# Compress Boot Image in a tar File for Odin/heimdall Flash
tar -c boot.img -f Mu-ja3gxx.tar||exit 1
mv boot.img Mu-ja3gxx.img||exit 1
