#! /system/bin/sh
# Program:
# Program creates by Vane and it is for WIFI only.
# This RX can operate independently,don't need anothers.
# History:
# 2012/03/20	Vane	Jorjin release

TARGET_FW_DIR=/system/etc/firmware/ti-connectivity
TARGET_FW_FILE=$TARGET_FW_DIR/wl1271-nvs.bin #This file
TARGET_NVS_FILE=/system/etc/wifi/TQS_S_2.6.ini #This is for TI module single band
#TARGET_NVS_FILE=/system/etc/wifi/TQS_D_1.7.ini #This is for TI module dual band
#TARGET_NVS_FILE=/system/etc/wifi/TQS_D_1.7_WG7550_NLCP.ini #for jorjin module dual band

CHANNEL="NULL"
POWER=""
BAND=""
MODULE=""
#DEF_MAC="00:11:22:33:44:55"
RANDOM_MAC=""


if [ ! -f $TARGET_FW_FILE ]; then
	echo " Error  cannot access NVS file: No such file or directory !!!!!"
	exit
fi


if [ ! -f $TARGET_FW_FILE ]; then
	echo " Error : cannot access NVS file: No such file or directory !!!!!"
	exit
fi

#***********************************************************
#		Calibrate function
#***********************************************************
calibration(){
	mount -o remount rw /system
	cd $TARGET_FW_DIR

	calibrator set ref_nvs $TARGET_NVS_FILE
	sleep 1
	cat ./new-nvs.bin > $TARGET_FW_FILE

	ifconfig wlan0 down #make wifi down
	rmmod wl12xx_sdio #check it is already remove wifi driver
	sleep 1
	insmod /system/lib/modules/wl12xx_sdio.ko #insert wifi driver module 
	sleep 1
	ifconfig wlan0 down #make wifi down
	echo " ~~~Start Calibration~~~ "
#	calibrator plt calibrate single #this is for single band modules
	calibrator plt calibrate dual  #this is for dual band modules
	sleep 1

	cat ./new-nvs.bin > $TARGET_FW_FILE

	calibrator set nvs_mac wl1271-nvs.bin $RANDOM_MAC #to produce random MAC
#	calibrator set nvs_mac wl128x-fw-4-plt.bin $RANDOM_MAC
#	echo "-------- Write Default MAC = $DEF_MAC ------------" #if we want to use for factory test...
	#sleep 1
	NOWMAC=$(calibrator get nvs_mac $TARGET_FW_FILE) #TI get WIFI MAC command
	NOWMAC=$(echo $NOWMAC | busybox awk '{print substr($0,20)}') #only show mac number
	echo "-------- Write Random MAC = $NOWMAC ------------"
	unset NOWMAC
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

}

#***********************************************************
#		Error type
#***********************************************************
error_type(){
	echo "
Error type, Please try again!!!!!"
sleep 1
busybox clear
}
#***********************************************************
#		WIFI Load
#***********************************************************
wifi_load() {
echo "
------------------------
-  WIFI Driver Loading -
------------------------"
	insmod /system/lib/modules/wl12xx_sdio.ko
	ifconfig wlan0 down
	busybox clear
#	sleep 1
}

#***********************************************************
#		WIFI Unload
#***********************************************************
wifi_unload() {
echo "
------------------------
-  WIFI Driver Unload  -
------------------------"       
	rmmod wl12xx_sdio
	busybox clear
#	sleep 1
}

#***********************************************************
#		WIFI set channel
#***********************************************************
#setchannel(){
#while [ 1 ]
#    do  
#read -p " 
#+++++++++++++++++++++++++++++++++++++++++++++++++++++
#                Set Channel  
#+++++++++++++++++++++++++++++++++++++++++++++++++++++
setchannel(){
while [ 1 ]
    do  
read -p " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Set Channel  
+++++++++++++++++++++++++++++++++++++++++++++++++++++

Please pass channel or pass Q to leave...

====>" CH
if [ "$CH" -gt 14 -a "$CH" -lt 36 ] ; then
error_type
busybox clear
break
elif [ "$CH" == "q"||"Q"] ; then
busybox clear
break
else
CHANNEL=$CH
calibrator wlan0 plt tune_channel 0 $CHANNEL
busybox clear
break
fi
    done
}
#Please pass channel or pass Q to leave...

#====>" CH
#case "$CH" in
#1)
#CHANNEL=1
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#2)
#CHANNEL=2
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#3)
#CHANNEL=3
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#4)
#CHANNEL=4
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#5)
#CHANNEL=5
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#6)
#CHANNEL=6
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#7)
#CHANNEL=7
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#8)
#CHANNEL=8
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#9)
#CHANNEL=9
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#10)
#CHANNEL=10
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#11)
#CHANNEL=11
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#12)
#CHANNEL=12
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#13)
#CHANNEL=13
#calibrator wlan0 plt tune_channel 0 $CHANNEL
#busybox clear
#break;;
#Q|q)
#busybox clear
#break;;
#*)
#error_type
#busybox clear
#;;
#esac
#   done
#}

#-------------------------------------- Main --------------------------------------
wifi_load
while [ 1 ]
do
echo "
++++++++++++++++++++++++++++++++++++++++++++++++++
               MAIN NENU -> WIFI NENU
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - Test TX Power

2) - Test RX Sensitivity

3) - Test Single Tone (CW)

4) - Calibration"
#check mac.sh file
if [ ! -f $MAC_SH ] ; then
  echo "
No mac.sh script! Can't change mac !!"
else
  echo "
5) - Change MAC address"
fi

echo "
Q) - Exit With Wifi Shut Down"
echo -n "
====> "
	read WIFI_OPT

	case "$WIFI_OPT" in
########### WIFI NENU - 1 ###########
	1) # 1) - Test TX Power
		wifi_load #Todo: must move to initial function.
		sleep 1
		calibrator wlan0 plt power_mode on
	while [ 1 ]
	do
		echo "
++++++++++++++++++++++++++++++++++++++++++++++++++
               WIFI NENU [Test TX]
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - Set Channel  (Now CHANNEL: CH $CHANNEL)

2) - Set Rate and Start Test

Q) - Exit"

echo -n "
====> "
	read TX_OPT
			case "$TX_OPT" in
				1)
					setchannel
					continue
					;;
				2)
					busybox clear
					export  TEMP=$CHANNEL
					./rate.sh
					continue
					;;
				q|Q)
					calibrator wlan0 plt power_mode off
					wifi_unload
					sleep 1
					break;;
				*)
					error_type
					;;
			esac
	done  
	;;

########### WIFI NENU - 2 ###########
	2) # 2) - Test RX Sensitivity
		wifi_load
		sleep 1
		calibrator wlan0 plt power_mode on
		sleep 1
	while [ 1 ]
	do    
		echo -n " 
++++++++++++++++++++++++++++++++++++++++++++++++++
               WIFI MENU [Test RX]
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - Set Channel  (Now CHANNEL: CH $CHANNEL)

2) - Start RX

Q) - Exit

====> "
		read RX_OPT
			case "$RX_OPT" in
				1)
					setchannel
					;;
				2)
					calibrator wlan0 plt tune_channel 0 $CHANNEL
					calibrator wlan0 plt stop_rx_statcs
					sleep 1
					calibrator wlan0 plt reset_rx_statcs
					calibrator wlan0 plt start_rx_statcs
					sleep 1
					busybox clear
					NOWMAC=$(calibrator get nvs_mac $TARGET_FW_FILE) #TI get WIFI MAC command
					NOWMAC=$(echo $NOWMAC | busybox awk '{print substr($0,20)}') #only show mac number

					while [ 1 ];	do

					read -p "
Your MAC is :$NOWMAC
Start testing RX...

Pass [t] to Stop RX...
===>" PAUSE

					if [ $PAUSE != "t"  ]; then
						echo "Type ERROR!! Please try again!! "
					else
						echo "Stop Run Rx  "
						calibrator wlan0 plt stop_rx_statcs
						sleep 1
						echo "--------- Get RX statistics ---------"
						calibrator wlan0 plt get_rx_statcs
						unset PAUSE
						break
					fi		
					done
					continue;; #back to    WIFI MENU [Test RX]
				3)
					calibrator wlan0 plt stop_rx_statcs
					sleep 1
					echo "--------- Get RX statistics ---------"
					calibrator wlan0 plt get_rx_statcs
					continue;;
				q|Q)
					calibrator wlan0 plt power_mode off
					sleep 1
					wifi_unload
					break;;
				*)
					error_type;;
			esac
	done
	;;
########### WIFI NENU - 3 ###########
	3)
		wifi_load
		sleep 1
		calibrator wlan0 plt power_mode on
		sleep 1
	while [ 1 ]
	do    
		echo -n " 
++++++++++++++++++++++++++++++++++++++++++++++++++
               WIFI MENU [Test CW]
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - Set Channel  (Now CHANNEL: CH $CHANNEL)

2) - Start CW

Q) - Exit

====> "
		read CW_OPT
	case "$CW_OPT" in
		1)
			calibrator wlan0 plt tx_stop
			setchannel
			continue;;
		2)
			calibrator wlan0 plt tx_tone 2 9000
			while [ 1 ]
				do
				read -p "Pass T to Stop CW..." PAUSE
						if [ $PAUSE == "T"  ]; then
						calibrator wlan0 plt tx_stop
							echo "Stopping CW "
							sleep 2
							busybox clear
							break
						else
							echo "Type ERROR!! Please try again!! "
						fi		
				done
			continue;;
		q|Q)
			calibrator wlan0 plt power_mode off
			sleep 1
			wifi_unload
			busybox clear
			break;;
		*)
			error_type;;
	esac
	done
	;;
########### WIFI NENU - 4 ###########
	4) # 4) - Calibration
		calibration
		echo "
calibration success !! 
File path=$TARGET_FW_FILE"
		exit #must to do this , otherwise you will got ./mac.sh error!!
		;;

########### WIFI NENU - 5 ###########
	5) # 5) - Change MAC address"
		if [ ! -f $MAC_SH ] ; then
				echo " [ERROR] Can't change MAC !! "
		else
				busybox clear
				./mac.sh
		fi
		;;

########### WIFI NENU - Q ###########
	q|Q) #Quit
       		#echo "Back to menu ..."
		busybox clear
        	exit
    		;;
    esac
done



