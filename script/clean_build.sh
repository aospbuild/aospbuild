#!/bin/bash

rm -rfv out/release-marlin*
rm -rfv out/target/product/marlin/obj/PACKAGING/
rm -rfv out/target/product/marlin/{boot.img,root,kernel,ramdisk*,recovery*,system*,vendor*}
rm -rfv /tmp/{tmp*,system*,vendor*,target*}
