#! /system/bin/sh

#***********************************************************
#		WIFI Load
#***********************************************************

echo "
------------------------
-  WIFI Driver Loading -
------------------------"
	insmod /system/lib/modules/wl12xx_sdio.ko
	ifconfig wlan0 down
#	busybox clear
#	sleep 1

