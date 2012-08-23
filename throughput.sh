#! /system/bin/sh

AP_SSID=""
DUT_IP=""
PC_IP=""
TEST_DURATION=""
INSER=""

#check the wifi driver insert success or not.
INSER=$(lsmod | busybox grep "^wl12xx_sdio")
INSER=$(echo "$INSER" | busybox awk -F' ' '{ print $1 }')

if [ "$INSER" != "wl12xx_sdio" ]; then
	insmod /system/lib/modules/wl12xx_sdio.ko
fi
ifconfig wlan0 $DUT_IP up
#***********************************************************
#		Get SSID Name
#***********************************************************
get_ssid_name(){
        CONNECTED_SSID=$(iw dev wlan0 link | busybox grep 'SSID:' | busybox sed 's/^.*SSID://g')
        CONNECTED_SSID=$(echo "$CONNECTED_SSID" | busybox awk -F' ' '{ print $1 }')
	DUT_IP=$(ifconfig wlan0 | busybox awk -F' ' '{ print $3 }' )
}
#***********************************************************
#		Error type
#***********************************************************
error_type(){
	echo "
Error type, Please try again!!!!!"
#sleep 1
busybox clear
}

#======================================================================
throughput_tx()
{
busybox clear
get_ssid_name
echo "AP name :$CONNECTED_SSID"
echo "DUT IP :$DUT_IP"
echo "Default Server IP :$RETEST_IP"
read -p"
*****************************
* If you want to retest TX, *
* don't need type IP !!     *
*****************************
Please type Server IP: 
or
keep type 'q' to leave

===>" TYPE_IP
if [ "$TYPE_IP" != "" ]; then #if you type address
RETEST_IP=$TYPE_IP
PC_IP=$RETEST_IP
#elif [ "$TYPE_IP" = "q" ]; then
#continue
fi

read -p"
Please type Test duration time:
or 
keep type 'q' to leave

ex: 60
===>" TEST_DURATION

if [ "$TYPE_IP" = "" ]; then #if you type enter, no type address
	RETEST_IP=$PC_IP
elif [ "$TYPE_IP" = "q" ]; then
busybox killall iperf
busybox clear
continue
else
	RETEST_IP=" null "
	RETEST_IP=$PC_IP
fi
		echo "[ Iperf Tx Start ; Test $TEST_DURATION secs ]"
		iperf -c $RETEST_IP -w64k -l16k -i1 -t$TEST_DURATION 

unset $RETEST_IP && $PC_IP && $TEST_DURATION && $TYPE_IP
}
#======================================================================
throughput_rx(){
busybox clear
while [ 1 ]; do
read -p"
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Throughput Rx Test Mode  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ 

 1. Rx start 

 2. Rx stop 

 q. Exit
====> " TP_R
case "$TP_R" in
1)
	get_ssid_name
	if [ "$AP_SSID" != "$CONNECTED_SSID" ]; then
		echo "[ Error!!! No Connection, please reconnect AP ]"
		break
	fi
	
        Server=$(ps | busybox grep 'iperf')

        if [ "$Server" != "" ]; then #if iperf still backrunning
		busybox killall iperf
		sleep 1
        fi
read -p"
Please type Test duration time:
or 
keep type 'q' to leave

ex: 60
===>" TEST_DURATION

        echo "[ iperf Rx Start ]"
	sleep 1
	busybox clear
        #echo "[ Please run client at PC ]"
        iperf -s -w64k -l16k -i1 -t$TEST_DURATION &
        continue
        ;;

2)
        busybox killall iperf
        echo "[ iperf Stop ]"
	sleep 1
	busybox clear
        continue
        ;;

 q)
        Server=$(ps | busybox grep 'iperf')
        if [ "$Server" != "" ]; then
	busybox killall iperf
        fi
        break
        ;;
*)
        error_type
        ;;
esac
done
}

#-------------------------------------- Main --------------------------------------
busybox clear
while [ 1 ]; do
read -p "
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Throughput Test Mode
+++++++++++++++++++++++++++++++++++++++++++++++++++++

1. Connect to AP 

2. Tx(Client) 

3. Rx(Server) 

q. Exit
====> " TP
case "$TP" in
1)
read -p "
Please Enter SSID Name Or Type 'q' Leave...
====> " SSID
#type 'q' to leave
if [ "$SSID" = "q"  ]; then
busybox clear
continue
fi

AP_SSID=$SSID

		get_ssid_name
	        if [ "$AP_SSID" != "$CONNECTED_SSID" ]; then
		echo "Connecting $AP_SSID ..."
		iw wlan0 connect $AP_SSID
	        fi
        sleep 1
	netcfg wlan0 dhcp #access DHCP
#	sleep 2
	DUT_IP=$(ifconfig wlan0 | busybox awk -F' ' '{ print $3 }' ) #select that data before the third space (' ') .

		get_ssid_name
	        if [ "$AP_SSID" == "$CONNECTED_SSID" ]; then
		busybox clear
		iw dev wlan0 link
		fi
        continue
        ;;
2)
        throughput_tx
        continue
        ;;
3)
        throughput_rx
        continue
        ;;
q|Q)
	iw wlan0 disconnect
        ifconfig wlan0 down
        rmmod wl12xx_sdio
        break
        ;;
*)
        error_type
        ;;
esac
echo " "     
done


