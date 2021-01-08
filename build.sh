#!/bin/bash
echo "--- Setup"
export USE_CCACHE="1"
#TODO(zif): convert this to a runtime check, grep "sse4_2.*popcnt" /proc/cpuinfo
export CPU_SSE42=false
# Following env is set from build
# DEVICE

echo "--- Syncing"

cd /aurora/australis
rm -rf .repo/local_manifests/*
if [ -f /aurora/setup.sh ]; then
    source /aurora/setup.sh
fi
yes | repo init -u https://github.com/aurora-rom/android.git -b australis
echo "Resetting build tree"
repo forall -vc "git reset --hard" > /tmp/android-reset.log 2>&1
echo "Syncing"
repo sync -j32 -d --force-sync > /tmp/android-sync.log 2>&1
. build/envsetup.sh


echo "--- clobber"
rm -rf out

echo "--- breakfast"
set +e
breakfast aurora_${DEVICE}-userdebug
set -e

if [[ "$TARGET_PRODUCT" != aurora_* ]]; then
    echo "Breakfast failed, exiting"
    exit 1
fi

echo "--- Building"
mka bacon > /tmp/android-build.log
