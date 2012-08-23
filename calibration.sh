#! /system/bin/sh

TARGET_FW_DIR=/system/etc/firmware/ti-connectivity
TARGET_FW_FILE=$TARGET_FW_DIR/wl1271-nvs.bin
TARGET_NVS_FILE=/system/etc/wifi/TQS_S_2.6.ini

	mount -o remount rw /system
	cd $TARGET_FW_DIR

	calibrator set ref_nvs $TARGET_NVS_FILE
	sleep 1
	cat ./new-nvs.bin > $TARGET_FW_FILE
	ifconfig wlan0 down
	rmmod wl12xx_sdio
	sleep 1
	insmod /system/lib/modules/wl12xx_sdio.ko
	sleep 1
	ifconfig wlan0 down
	echo " ~~~Start Calibration~~~ "
	calibrator plt calibrate single
	sleep 1
	cat ./new-nvs.bin > $TARGET_FW_FILE
	sleep 1
	calibrator set nvs_mac $TARGET_FW_FILE
	sleep 1
	echo "-------- Reset WIFI ------------"
	rmmod wl12xx_sdio
	rmmod wl12xx
	sleep 1
	insmod /system/lib/modules/wl12xx.ko
	insmod /system/lib/modules/wl12xx_sdio.ko
	echo "-------- Remove ./new-nvs.bin------------"
	rm  ./new-nvs.bin
	echo "-------- WIFI calibrate success ------------"

