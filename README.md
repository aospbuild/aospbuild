### Steps for building

Follow this guid to establish a build environment: https://source.android.com/setup/build/initializing

Download "repo"

	mkdir ~/bin
	PATH=~/bin:$PATH
	curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
	chmod 755 ~/bin/repo
	
Create work folder

	mkdir aosp
	cd aosp
	
Find your build number here https://developers.google.com/android/ota , and your branch from here https://source.android.com/setup/start/build-numbers#source-code-tags-and-builds .
For the Pixel 1 XL (marlin) latest buid number is OPM4.171019.016.B1 and the corresponding branch number is android-8.1.0_r28	

Initialize the repo

	repo init -u https://android.googlesource.com/platform/manifest -b android-8.1.0_r28
	
Download the source

	repo sync -j16
	
Generate your signing keys

 For Nexuses and Pixel 1 (XL)
 
 	mkdir -p keys/marlin
	cd keys/marlin
	../../development/tools/make_key releasekey '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	../../development/tools/make_key platform '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	../../development/tools/make_key shared '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	../../development/tools/make_key media '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	../../development/tools/make_key verity '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	cd ../..
	
	make -j20 generate_verity_key
	out/host/linux-x86/bin/generate_verity_key -convert keys/marlin/verity.x509.pem keys/marlin/verity_key
	
For Pixel 2 (XL)
	 
	mkdir -p keys/taimen
	cd keys/taimen
	../../development/tools/make_key releasekey '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	../../development/tools/make_key platform '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	../../development/tools/make_key shared '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	../../development/tools/make_key media '/C=US/ST=Some-State/L=Some-City/O=Aosp/OU=Aosp/CN=Aosp/emailAddress=user@host.com'
	openssl genrsa -out avb.pem 2048
	../../external/avb/avbtool extract_public_key --key avb.pem --output 
	cd ../..
	
avb_pkmd.bin will be needed for flashing


For Pixel 1 and Piexl 1 XL, verity_key must be included in the kernel, and the kernel rebuilt

Download kernel source

	git clone https://android.googlesource.com/kernel/msm

Find the prebuilt kernel version

	lz4cat device/google/marlin-kernel/Image.lz4-dtb | grep -a 'Linux version' | cut -d ' ' -f3 | cut -d'-' -f2 | sed 's/^g//g'
	
At the moment kernel version for 'marlin' is 514a3ff917ea

	cd msm
	git checkout 514a3ff917ea
	openssl x509 -outform der -in ../keys/marlin/verity.x509.pem -out verity_user.der.x509
	export ARCH=arm64
	export CROSS_COMPILE=aarch64-linux-android-
	make marlin_defconfig
	make -j20
	mv arch/arm64/boot/Image.lz4-dtb ../device/google/marlin-kernel/
	cd ..
	
Clone this repo

	cd ..
	git clone https://github.com/aospbuild/aospbuild
	cp -av aospbuild/* aosp/
	cd aosp
	
Prepare FDroid Priviledged Extension

	fingerprint=`openssl x509 -noout -fingerprint -sha256 -inform pem -in keys/marlin/platform.x509.pem | cut -d'=' -f2 | sed 's/://g' | tr '[:upper:]' '[:lower:]'`
	sed -i "s/SHA256_FINGERPRINT/$fingerprint/g" external/extras/FDroidPriviledged/java/org/fdroid/fdroid/privileged/ClientWhitelist.java
	
If you skip this step, the priviledged extension will not accept your signed FDroid.

Prepare vendor files

	cd ..
	git clone https://github.com/anestisb/android-prepare-vendor
	cd android-prepare-vendor
	mkdir out
	./execute-all.sh -d marlin -b OPM4.171019.016.B1 -o out
	cp -av out/marlin/opm4.171019.016.b1/vendor* ../aosp/
	cd ../aosp
	
Note: on some setups, there might be some issues with android-prepare-vendor. You might need to make some changes to execute-all.sh lines 325-327 as follows:

	  USE_DEBUGFS=false
  	SYS_TOOLS+=("fusermount")
  	_UMOUNT="fusermount -u"
	
Building

	source script/aosp.sh
	choosecombo release aosp_marlin user
	make -j20 brillo_update_payload && make target-files-package -j24 && script/release.sh marlin
	
	
	
	
