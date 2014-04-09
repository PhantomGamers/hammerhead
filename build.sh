[ -e boot.img ] && rm -f boot.img
[ -e franco.Kernel-nightly-dt2w.zip ] && rm -f franco.Kernel-nightly-dt2w.zip
make mrproper

if [ $# -gt 0 ]; then
VER=`expr $1 - 1`
echo $VER > .version
fi

schedtool -B -n 1 -e ionice -n 1 make -j$(cat /proc/cpuinfo | grep "^processor" | wc -l) franco_defconfig
schedtool -B -n 1 -e ionice -n 1 make -j$(cat /proc/cpuinfo | grep "^processor" | wc -l)

if [ -e arch/arm/boot/zImage-dtb ]; then

cp arch/arm/boot/zImage-dtb ../ramdisk_hammerhead/

cd ../ramdisk_hammerhead/

echo "making ramdisk"
./mkbootfs boot.img-ramdisk | gzip > ramdisk.gz
echo "making boot image"
./mkbootimg --kernel zImage-dtb --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --ramdisk ramdisk.gz --output ../hammerhead/boot.img

rm -rf ramdisk.gz
rm -rf zImage

cd ../hammerhead/

zipfile="franco.Kernel-nightly-dt2w.zip"
echo "making zip file"
[ -e zip/boot.img ] && rm -f zip/boot.img
cp boot.img zip/

cd zip/
rm -f *.zip
zip -r -9 $zipfile *
rm -f /tmp/*.zip
cp *.zip /tmp

else

echo "build failed"
fi
