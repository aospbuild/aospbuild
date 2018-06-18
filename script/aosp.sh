source build/envsetup.sh

export LANG=C
export _JAVA_OPTIONS=-XX:-UsePerfData
export BUILD_NUMBER=$(cat out/build_number.txt 2>/dev/null || date --utc +%Y.%m.%d.%H)
echo "BUILD_NUMBER=$BUILD_NUMBER"
export DISPLAY_BUILD_NUMBER=true
export OFFICIAL_BUILD=true
chrt -b -p 0 $$
export PATH="$PWD/script/bin:$PATH"

sed -i 's/<bool name="config_enableAutoPowerModes">false<\/bool>/<bool name="config_enableAutoPowerModes">true<\/bool>/g' frameworks/base/core/res/res/values/config.xml
