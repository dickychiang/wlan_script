#! /system/bin/sh
# Program:
# Program creates by Vane and it is MAC only.
# History:
# 2012/03/14	Vane	Jorjin release

######################################
#					MAC
######################################

TARGET_FW_DIR=/system/etc/firmware/ti-connectivity
TARGET_FW_FILE=$TARGET_FW_DIR/wl1271-nvs.bin
TARGET_NVS_FILE=/system/etc/wifi/TQS_S_2.6.ini #This is for TI module single band
#TARGET_NVS_FILE=/system/etc/wifi/TQS_D_1.7.ini #This is for TI module dual band
#TARGET_NVS_FILE=/system/etc/wifi/TQS_D_1.7_WG7550_NLCP.ini #for jorjin module dual band
#***********************************************************
#                Set Mac Address
#***********************************************************
#MACADDRESS="$M1:$M2:$M3:$M4:$M5:$M6"
while [ 1 ]
do

echo " 
++++++++++++++++++++++++++++++++++++++++++++++++++
               WIFI MENU [Mac Address]
++++++++++++++++++++++++++++++++++++++++++++++++++"
	
	cd $TARGET_FW_DIR
	OLDMAC=$(calibrator get nvs_mac $TARGET_FW_FILE) #TI get WIFI MAC command
	OLDMAC=$(echo $OLDMAC | busybox awk '{print substr($0,20)}') #only show mac number
echo "
Old MAC address : $OLDMAC
Please type new MAC address "
read -p "(Ex: 12:34:56:78:90:AB !! ) 
====>  " MAC

MAC_LEN=""
MAC_LEN=${#MAC} 
#check MAC length

if [ ! $MAC_LEN -eq 17 ] ; then #17bits
echo "MAC length= $MAC_LEN" #
echo "MAC won't be change!!"
#ERROR MAC ADDRESS!!!"
#sleep 2
#busybox clear
exit
fi

TR_MAC=$(echo $MAC | busybox tr  "[:lower:]" "[:upper:]") #lowercase switch to uppercase

M1=$(echo "$TR_MAC" | busybox awk -F: '{ print $1 }')
M2=$(echo "$TR_MAC" | busybox awk -F: '{ print $2 }')
M3=$(echo "$TR_MAC" | busybox awk -F: '{ print $3 }')
M4=$(echo "$TR_MAC" | busybox awk -F: '{ print $4 }')
M5=$(echo "$TR_MAC" | busybox awk -F: '{ print $5 }')
M6=$(echo "$TR_MAC" | busybox awk -F: '{ print $6 }') 
# awk -F":" '{ print $1 }'-->Specify each line use ":" to separate string, and "print $1" means print out the first string after ":".
NEW_MAC="$M1:$M2:$M3:$M4:$M5:$M6"
#todo:	if type error will show some messages
	calibrator set nvs_mac $TARGET_FW_FILE $NEW_MAC #This is for 127x
#	calibrator set nvs_mac wl128x-fw-4-plt.bin $NEW_MAC
	sleep 1
	unset MAC  #free local variable "$MAC"
	rmmod wl12xx_sdio
	rmmod wl12xx
	echo "unload wifi ... "
	sleep 1
	insmod /system/lib/modules/wl12xx.ko
	insmod /system/lib/modules/wl12xx_sdio.ko
	echo "load wifi ... "
	sleep 1
	break
done



