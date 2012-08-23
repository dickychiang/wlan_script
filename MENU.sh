#!/system/bin/sh
# Program:
# Program creates by Vane and it is Menu only.
# History:
# 2012/03/09	Vane	Jorjin release

######################################
#					MAIN NENU					       #
######################################
#CURRENT_PATH=/system/etc/wifi
CURRENT_PATH=$(pwd)
WIFI_SH=$CURRENT_PATH/wifi.sh
MAC_SH=$CURRENT_PATH/mac.sh
BT_SH=$CURRENT_PATH/bt.sh
GPS_SH=$CURRENT_PATH/gps.sh
CAL_SH=$CURRENT_PATH/calibration.sh
THROUGHPUT_SH=$CURRENT_PATH/throughput.sh

chmod 777 ./*.sh
busybox clear
while [ 1 ]
do

echo "
++++++++++++++++++++++++++++++++++++++++++++++++++
               MAIN NENU
++++++++++++++++++++++++++++++++++++++++++++++++++"
#########################
	if [ ! -f $WIFI_SH ] ; then
	echo "No WIFI script! Can't test WIFI !!
"
	else
	echo "1) - WIFI Test
"
	fi
#########################
	if [ ! -f $BT_SH ] ; then
	echo "No BT script! Can't test BT !!
"
	else
	echo "2) - BT Test
"
	fi
#########################
	if [ ! -f $GPS_SH ] ; then
	echo "No GPS script! Can't test GPS !!
"
	else
	echo "3) - GPS Test
"
	fi
#########################
	if [ ! -f $THROUGHPUT_SH ] ; then
	echo "No throughput script! Can't test throughput !!
"
	else
	echo "4) - WIFI Throughput
"
	fi
#########################
	echo "Q) - Exit With Wifi Shut Down
"
	echo -n "====> "
read MAIN_OPT
	case "$MAIN_OPT" in
1)
	busybox clear
	./wifi.sh
;;
2)
	busybox clear
	./bt.sh
;;
3)
	busybox clear
	./gps.sh
;;
4)
	busybox clear
	./throughput.sh
;;
q|Q)
	echo "$WIFI_SH"
        echo "Exit...."
        exit                                                  
;;
    esac
done
