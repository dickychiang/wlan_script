#!/system/bin/sh

TARGET_FW_DIR=/system/etc/firmware/ti-connectivity
TARGET_FW_FILE=$TARGET_FW_DIR/wl1271-nvs.bin
TARGET_FW_MAC_FILE=$TARGET_FW_DIR/mac_address.txt
#TARGET_NVS_FILE=/system/etc/wifi/TQS_S_2.6.ini
TARGET_NVS_FILE=/system/etc/wifi/WG7550-X0-INI-R02_TQS_D_1.8.ini
TARGET_BT_SCRIPT=/system/etc/firmware/TIInit_10.6.15.bts
#TARGET_BT_SCRIPT=/system/etc/firmware/TIInit_7.2.31.bts

CHANNEL="1"
POWER=""
BAND=""
MODULE=""
MAC="00:c9:82:48:ed:ff"
REAL_MAC=""
TMP=""

AP_SSID="iperf"
DUT_IP="192.168.0.13"
PC_IP="192.168.0.234"
TEST_DURATION=10



#======================================================================
pass(){

echo "*********   ********   **********  **********  "
echo "*       *   *      *   *           *           "
echo "*       *   *      *   *           *           "
echo "*********   ********   **********  **********  "
echo "*           *      *            *           *  "
echo "*           *      *            *           *  "
echo "*           *      *   **********  **********  "
}
#======================================================================
fail(){				
echo "*********   ********   **********  *           "
echo "*           *      *       *       *           "
echo "*           *      *       *       *           "
echo "*********   ********       *       *           "
echo "*           *      *       *       *           "
echo "*           *      *       *       *           "
echo "*           *      *   **********  **********  "
}
#======================================================================
# make sure wifi is not enable before running this script.
WIFION=`getprop init.svc.wpa_supplicant`
case "$WIFION" in
  "running") 
             echo " ********************************************************"
             echo " * Turn Wi-Fi OFF and launch the script 		   *"
             echo " ********************************************************"
             exit;;
          *) 
             echo " ******************************"
             echo " * Starting Script            *"
             echo " ******************************";;
esac

if [ ! -f $TARGET_FW_FILE ]; then
	echo " Error : cannot access wl1271-nvs.bin: No such file or directory !!!!!"
	exit
fi


if [ ! -f $TARGET_NVS_FILE ]; then
	echo " Error : cannot access TQS_S_2.6.ini: No such file or directory !!!!!"
	exit
fi


if [ ! -f $TARGET_BT_SCRIPT ]; then
        echo " Error : cannot access TIInit_10.6.15.bts: No such file or directory !!!!!"
        exit
fi

if [ -f $TARGET_FW_MAC_FILE ]       
then
pass
else
fail
fi

#======================================================================
bttestmode(){
while [ 1 ]
    do
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Bluetooth Test Mode  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " 1. Entering BT Test Mode "
echo " 2. Disable BT "
echo "q.Exit"           
echo -n "====> "
read BT
case "$BT" in
1)
bttest enable
sleep 1
hcitool cmd 0x3f 0x10c 0x00 0x00 0x00 0xff 0xff 0xff 0xff 0x64
hcitool cmd 0x03 0x1a 0x03
hcitool cmd 0x03 0x05 0x02 0x00 0x03
hcitool cmd 0x06 0x03
sleep 1
echo "----------------------------------------"
echo "-  BlueTooth Test Mode Start !!!	     -"
echo "----------------------------------------"
continue
;;
2)
bttest disable
sleep 1
echo "----------------------------------------"
echo "-  BlueTooth Test Mode Disable !!!     -"
echo "----------------------------------------"
continue
;;
q)
break
;;
*)
error_type
;;
esac
echo " "     
done
}

#======================================================================
throughput_rx(){
while [ 1 ]
    do
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Throughput Rx Test Mode  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " 1. Rx start "
echo " 2. Rx stop "
echo " q. Exit"           
echo -n "====> "
read TP_R
case "$TP_R" in
1)
	CONNECT_SSID=$(iw wlan0 link | busybox grep 'SSID:' | busybox sed 's/^.*SSID://g')
	CONNECT_SSID=$(echo "$CONNECT_SSID" | busybox awk -F' ' '{ print $1 }')


	if [ "$AP_SSID" != "$CONNECT_SSID" ]
		then
		echo "[ Error!!! No Connection, please reconnect AP ]"
		break
	fi
	
        Server=$(ps | busybox grep 'iperf')

        if [ "$Server" != "" ]
        then
		busybox killall iperf
		sleep 1
        fi

        echo "[ iperf Rx Start ]"
        echo "[ Please run client at PC ]"

        iperf -s -w64k -l16k -i1 -t$TEST_DURATION &
        continue
        ;;

2)
        busybox killall iperf
        echo "[ iperf Stop ]"
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
        echo " "     
        done

}
#======================================================================
throughput_tx()
{
CONNECT_SSID=$(iw wlan0 link | busybox grep 'SSID:' | busybox sed 's/^.*SSID://g')
CONNECT_SSID=$(echo "$CONNECT_SSID" | busybox awk -F' ' '{ print $1 }')

	if [ "$AP_SSID" == "$CONNECT_SSID" ]; then
		echo "[ Please make sure the Server had been run on PC ]"
		echo "[ Iperf Tx Start ; Test $TEST_DURATION secs ]"
		iperf -c $PC_IP -w64k -l16k -i1 -t$TEST_DURATION 
	else 
		echo "[ Error!!! No Connection, please reconnect AP ]"		
	fi
}

#======================================================================
throughputtest()
{
TIMEOUT_COUNT=1
RETRY=1
insmod /system/lib/modules/wl12xx_sdio.ko
ifconfig wlan0 $DUT_IP up

while [ 1 ]
    do
    echo " "  
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Throughput Test Mode  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo " 1. Connect to AP "
echo " 2. Tx(Client) "
echo " 3. Rx(Server) "
echo " q. Exit"           
echo -n "====> "
read TP
case "$TP" in
1)
        #insmod /system/lib/modules/wl12xx_sdio.ko
        #ifconfig wlan0 $DUT_IP up

        CONNECT_SSID=$(iw wlan0 link | busybox grep 'SSID:' | busybox sed 's/^.*SSID://g')
        CONNECT_SSID=$(echo "$CONNECT_SSID" | busybox awk -F' ' '{ print $1 }')


	        if [ "$AP_SSID" != "$CONNECT_SSID" ]
		        then
		        iw wlan0 connect $AP_SSID
	        fi
        sleep 1

        while [ "$TIMEOUT_COUNT" != "5" ]
        do
	        CONNECT_SSID=$(iw wlan0 link | busybox grep 'SSID:' | busybox sed 's/^.*SSID://g')
	        CONNECT_SSID=$(echo "$CONNECT_SSID" | busybox awk -F' ' '{ print $1 }')


	        if [ "$AP_SSID" == "$CONNECT_SSID" ]
		        then
		        echo "[ Connection exstablished ]"
		        break				
	        else 
		        sleep 1
		        TIMEOUT_COUNT=$(($TIMEOUT_COUNT+1))
		        if [ "$TIMEOUT_COUNT" == "4" ]
		        then
			        iw wlan0 connect $AP_SSID
			        echo "[ Retry connect ]"

			        while [ "$RETRY" != "3" ]
			        do

        CONNECT_SSID=$(iw wlan0 link | busybox grep 'SSID:' | busybox sed 's/^.*SSID://g')
        CONNECT_SSID=$(echo "$CONNECT_SSID" | busybox awk -F' ' '{ print $1 }')


                if [ "$AP_SSID" == "$CONNECT_SSID" ]
	                then
	                echo "[ Connection exstablished ]"
	                break				
                else 
	                RETRY=$(($RETRY+1))
	                if [ "$RETRY" == "2" ] ; then 
		                echo "[ Error!!! Connection failed ]"
	                fi
	                sleep 1
                fi
                done
                break
        fi


	        fi
                done 
                TIMEOUT_COUNT=1
                RETRY=1
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
q)
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
}

setmac(){
while [ 1 ]
    do
echo " "  
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Set Mac Address  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "


echo -n "====> "
read MAC        
echo "---------------------------"
echo "| MAC address is $MAC |"
echo "---------------------------"
break
                                  
                                  
       done
}

calibrate(){
#if mac_address.txt exist, remove it.
if [ -f $TARGET_FW_MAC_FILE ]; then 
rm -r $TARGET_FW_MAC_FILE
fi
#enable BT and get bt mac
bttest enable
echo "[Start getting BT Address]"
sleep 1
MAC=$(hciconfig hci0 | busybox grep 'BD Address'| busybox sed 's/^.*BD Address://g'| busybox sed 's/ ACL.*$//g')
#echo "[BD MAC : $MAC]"
sleep 1
MAC=$(echo "$MAC" | busybox awk -F' ' '{ print $1 }')
#echo "[BD MAC : $MAC]"
bttest disable
LEN=0
MAC_INC=1
#check mac address length
LEN=${#MAC}

if [ $LEN -gt 17 ] #17bits
then
echo "LEN=$LEN"
echo "ERROR MAC ADDRESS!!!"
exit
fi

#echo "BT MAC:"
#echo "$MAC"

echo "*************************************"
echo "Processing MAC for WIFI"
M1=$(echo "$MAC" | busybox awk -F: '{ print $1 }')
M2=$(echo "$MAC" | busybox awk -F: '{ print $2 }')
M3=$(echo "$MAC" | busybox awk -F: '{ print $3 }')
M4=$(echo "$MAC" | busybox awk -F: '{ print $4 }')
M5=$(echo "$MAC" | busybox awk -F: '{ print $5 }')
M6=$(echo "$MAC" | busybox awk -F: '{ print $6 }') 

echo "*************************************"


#************************************************************************
D6=$(printf "%d\n" 0x$M6)
#D6=$(echo "ibase=16; $M6"| bc) #To convert to decimal, set ibase to 16
C6=$(( D6+$MAC_INC )) #+1
if [ $C6 -gt 255 ]
then
        echo "M5 need added 1"
	M6=00 #$(echo "obase=16; 00"|bc) #To convert to hexadecimal, set obase to 16

	#************************************************************************
	D5=$(printf "%d\n" 0x$M5)
	#D5=$(echo "ibase=16; $M5"|bc) #To convert to decimal, set ibase to 16
	C5=$(( D5+$MAC_INC ))
	if [ $C5 -gt 255 ]
	then
		echo " M4 need added 1"
		M5=00 #$(echo "obase=16; 00"|bc) #To convert to hexadecimal, set obase to 16
	#echo "M5=$M5"

	#************************************************************************
	D4=$(printf "%d\n" 0x$M4)	
	#D4=$(echo "ibase=16; $M4"|bc) #To convert to decimal, set ibase to 16
	C4=$(( D4+$MAC_INC ))
	if [ $C4 -gt 255 ]
	then
		echo " M3 need added 1"
		M4=00 #$(echo "obase=16; 00"|bc) #To convert to hexadecimal, set obase to 16
		#echo "M4=$M4"

	#************************************************************************
	D3=$(printf "%d\n" 0x$M3)
	#D3=$(echo "ibase=16; $M3"|bc) #To convert to decimal, set ibase to 16
	C3=$(( D3+$MAC_INC ))
	if [ $C3 -gt 255 ]
	then
		echo " M2 need added 1"
		M3=00 #$(echo "obase=16; 00"|bc) #To convert to hexadecimal, set obase to 16
		#echo "M3=$M3"

	#************************************************************************
		D2=$(printf "%d\n" 0x$M2)
		#D2=$(echo "ibase=16; $M2"|bc) #To convert to decimal, set ibase to 16
		C2=$(( D2+$MAC_INC ))
		if [ $C2 -gt 255 ]
		then
			echo " M1 need added 1"
			M2=00 #$(echo "obase=16; 00"|bc) #To convert to hexadecimal, set obase to 16
			#echo "M2=$M2"

	#************************************************************************
	D1=$(printf "%d\n" 0x$M1)
	#D1=$(echo "ibase=16; $M1"|bc) #To convert to decimal, set ibase to 16
	C1=$(( D1+$MAC_INC ))
	if [ $C1 -gt 255 ]
	then
		M1=00 #$(echo "obase=16; 00"|bc) #To convert to hexadecimal, set obase to 16
		#echo "M1=$M1"
#***************************END******************************************

	MACADDRESS="$M1:$M2:$M3:$M4:$M5:$M6"
	echo $MACADDRESS #print MACADDRESS
	echo "********ERROR MAC ADDRESS**************"
	else
	#D1=$C1
	#M1=$(echo "obase=16; $D1"|bc)
	M1=$(printf "%X\n" $C1)
	if [ $C1 -le 15 ]
	then
	M1="0$M1"
	fi
	#echo "M1=$M1"
fi
				else
#D2=$C2
#M2=$(echo "obase=16; $D2"|bc)
M2=$(printf "%X\n" $C2)
if [ $C2 -le 15 ]
then
M2="0$M2"
fi
#echo "M2=$M2"
				fi

			else
				#D3=$C3
				#M3=$(echo "obase=16; $D3"|bc)
				M3=$(printf "%X\n" $C3)
				if [ $C3 -le 15 ]
				then
				M3="0$M3"
				fi
				#echo "M3=$M3"
			fi
		else
			#D4=$C4
			#M4=$(echo "obase=16; $D4"|bc)
			M4=$(printf "%X\n" $C4)
			if [ $C4 -le 15 ]
			then
			M4="0$M4"
			fi
			#echo "M4=$M4"
		fi
	else
		#D5=$C5
		#M5=$(echo "obase=16; $D5"|bc)
		M5=$(printf "%X\n" $C5)
		if [ $C5 -le 15 ]
		then
		M5="0$M5"
		fi
		#echo "M5=$M5"
	fi
else
	#D6=$C6
	#M6=$(echo "obase=16; $D6"|bc)
	M6=$(printf "%X\n" $C6)
	if [ $C6 -le 15 ]
	then
	M6="0$M6"
	fi
	#echo "M6=$M6"
fi

MACADDRESS="$M1:$M2:$M3:$M4:$M5:$M6"
echo $MACADDRESS

#echo "[ BD MAC is $MAC | WIFI MAC is $MACADDRESS ]"


sleep 1
#mount -o remount rw /system
cd $TARGET_FW_DIR
calibrator set ref_nvs $TARGET_NVS_FILE
sleep 1
cat ./new-nvs.bin > $TARGET_FW_FILE
				        #ifconfig wlan0 down
#rmmod wl12xx_sdio
insmod /system/lib/modules/wl12xx_sdio.ko
sleep 1
ifconfig wlan0 down
echo "[ start calibration ]"

#calibrator plt calibrate single
#calibration and check fail(error) or pass
TMP=$(calibrator plt calibrate dual | busybox grep "Fail" | busybox sed 's/ to.*$//g')
if [ "$TMP" == "Fail" ]; then
fail
break
fi
echo "[ end calibration ]"

#cp new-nvs.bin to wl1271-nvs.bin and write wifi mac
sleep 1
cat ./new-nvs.bin > $TARGET_FW_FILE
calibrator set nvs_mac wl1271-nvs.bin $MACADDRESS
#echo "[ write MAC = $MACADDRESS ]"
sleep 1

#get mac(REAL mac) from nvs file 
REAL_MAC=$(calibrator get nvs_mac $TARGET_FW_FILE)
REAL_MAC=$(echo $REAL_MAC | busybox awk '{print substr($0,20)}')
MACADDRESS=$(echo $MACADDRESS | busybox tr A-Z a-z)

                  			#compare the mac from nvs with target mac
#if pass, store the mac to "mac_address.txt"
if [ $MACADDRESS == $REAL_MAC ]
then
echo "[BT MAC = $MAC ]"
echo "[Wifi MAC = $MACADDRESS]"
echo "BT MAC    =$MAC "	> mac_address.txt				
echo "Wifi MAC =$MACADDRESS " >> mac_address.txt
pass
else
fail
fi

#unload driver and reload driver
rmmod wl12xx_sdio
rmmod wl12xx
insmod /system/lib/modules/wl12xx.ko
sleep 1


}

error_type(){
	echo " "
	echo "Error type, Please try again!!!!!"
  echo " "
}


wifi_load() {

	insmod /system/lib/modules/wl12xx_sdio.ko
	ifconfig wlan0 down
	sleep 1

	
echo	"------------------------"
echo	"-  WIFI Driver Init    -"
echo	"------------------------"
}

wifi_unload() {

				

				rmmod wl12xx_sdio
				sleep 1
				
echo "------------------------"
echo "-  WIFI Driver Unload  -"
echo "------------------------"
       
}

calibration()
{
while [ 1 ]
    do  
    echo " "  
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                calibration
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "

TARGET_FW_DIR=/system/etc/firmware/ti-connectivity
TARGET_FW_FILE=$TARGET_FW_DIR/wl1271-nvs.bin
echo "1.Enter MAC"
echo "2.Calibration "
echo "q.Exit"  		
echo -n "====> "
read K
case "$K" in
1)
setmac
continue
	;;
2)				
calibrate	
continue
	;;
q)
sleep 1
break
	;;
*)
error_type
	;;
esac    
echo " "     
done
}

tx_80211b(){
while [ 1 ]
    do  
    echo " "  
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                802.11b  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo "1.802.11 B = 11M   , CHANNEL = 1"
echo "2.802.11 B = 11M   , CHANNEL = 7"
echo "3.802.11 B = 11M   , CHANNEL = 13"
echo "q.Exit"  		
echo -n "====> "
read B
case "$B" in
1)
CHANNEL=1
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00000020 1000 0 20000 10000 3 1 0 0 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
   		  	                ;;
2)
CHANNEL=7
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00000020 1000 0 20000 10000 3 1 0 0 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
3)
CHANNEL=13
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00000020 1000 0 20000 10000 3 1 0 0 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
q)
calibrator wlan0 plt tx_stop
sleep 1
echo "----------------------------------------"
echo "-         Cont. Tx Power Stop          -"
echo "----------------------------------------"
break
;;
*)
error_type
;;
esac    
echo " "     
done  
}
tx_80211g(){
while [ 1 ]
    do  
    echo " "  
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                802.11g  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo "1.802.11 G = 54M   , CHANNEL = 1"
echo "2.802.11 G = 54M   , CHANNEL = 7"
echo "3.802.11 G = 54M   , CHANNEL = 13"
echo "4.802.11 G = 54M   , CHANNEL = 36"
echo "5.802.11 G = 54M   , CHANNEL = 100"
echo "6.802.11 G = 54M   , CHANNEL = 165"
echo "q.Exit"  		
echo -n "====> "
read G
case "$G" in
1)
CHANNEL=1
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00001000 1000 0 20000 10000 3 1 0 4 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
2)
CHANNEL=7
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
				        calibrator wlan0 plt tx_cont 20 0x00001000 1000 0 20000 10000 3 1 0 4 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
3)
CHANNEL=13
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00001000 1000 0 20000 10000 3 1 0 4 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
4)
CHANNEL=36
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 1 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00001000 1000 0 20000 10000 3 1 0 4 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
5)
CHANNEL=100
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 1 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00001000 1000 0 20000 10000 3 1 0 4 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
6)
CHANNEL=165
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 1 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00001000 1000 0 20000 10000 3 1 0 4 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
q)
calibrator wlan0 plt tx_stop
sleep 1
echo "----------------------------------------"
echo "-         Cont. Tx Power Stop          -"
echo "----------------------------------------"
break
;;
*)
error_type
;;
esac    
echo " "     
done  
}
tx_80211n(){
while [ 1 ]
do  
echo " "  
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                802.11n  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "
echo "1.802.11 N = MCS7   , CHANNEL = 1"
echo "2.802.11 N = MCS7   , CHANNEL = 7"
echo "3.802.11 N = MCS7   , CHANNEL = 13"
echo "4.802.11 N = MCS7   , CHANNEL = 36"
echo "5.802.11 N = MCS7   , CHANNEL = 100"
echo "6.802.11 N = MCS7   , CHANNEL = 165"
echo "q.Exit"  		
echo -n "====> "
read N
case "$N" in
1)
CHANNEL=1
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00100000 1000 0 20000 10000 3 1 0 6 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
2)
CHANNEL=7
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00100000 1000 0 20000 10000 3 1 0 6 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
3)
CHANNEL=13
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 0 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00100000 1000 0 20000 10000 3 1 0 6 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
4)
CHANNEL=36
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 1 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00100000 1000 0 20000 10000 3 1 0 6 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
5)
CHANNEL=100
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 1 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00100000 1000 0 20000 10000 3 1 0 6 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
6)
CHANNEL=165
calibrator wlan0 plt tx_stop
sleep 1
calibrator wlan0 plt tune_channel 1 $CHANNEL
echo "----------------------------------------"
echo "-  Output Tx power on channel $CHANNEL -"
echo "----------------------------------------"
calibrator wlan0 plt tx_cont 20 0x00100000 1000 0 20000 10000 3 1 0 6 0 1 1 1 DE:AD:BE:EF:00:00
sleep 1
continue
;;
q)
calibrator wlan0 plt tx_stop
sleep 1
echo "----------------------------------------"
echo "-         Cont. Tx Power Stop          -"
echo "----------------------------------------"
break
;;
*)
error_type 
;;
esac    
echo " "     
done  
}

setchannel(){
while [ 1 ]
    do  
echo " "  
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
                Set Channel  
+++++++++++++++++++++++++++++++++++++++++++++++++++++ 
2.4G : Ch1 ~ Ch13
5G : Ch36, Ch100, Ch165
"
echo -n "====> "
          read C
          case "$C" in
1)
CHANNEL=1
break
;;
2)
CHANNEL=2
break
;;
3)
CHANNEL=3
break
;;
4)
CHANNEL=4
break
;;
5)
CHANNEL=5
break
;;
6)
CHANNEL=6
break
;;
7)
CHANNEL=7
break
;;
8)
CHANNEL=8
break
;;
9)
CHANNEL=9
break
;;
10)
CHANNEL=10
break
;;
11)
CHANNEL=11
break
;;
12)
CHANNEL=12
break
;;
13)
CHANNEL=13
break
;;
36)
CHANNEL=36
break
;;
100)
CHANNEL=100
break
;;
165)
CHANNEL=165
break
;;
q)
break
;;
*)
error_type
;;
esac
       done   
}

echo "

!!!!!!!!!!! Start from the MAIN MENU !!!!!!!!!!!!!!!!!"

while [ 1 ]
do

    echo  -n "
+++++++++++++++++++++++++++++++++++++++++++++++++++++
               MAIN NENU
+++++++++++++++++++++++++++++++++++++++++++++++++++++
    1 - Calibration
    2 - Tx Power Test
    3 - Rx Sensitivity Test
    4 - Bluetooth Test Mode
    5 - Throughput Test
    q - Exit With Wifi Shut Down
====> "

    read MAIN_OPT

    case "$MAIN_OPT" in
    1)
calibrate
;;
    2)
#       Test TX Power
sleep 1
wifi_load 
calibrator wlan0 plt power_mode on
sleep 1
	while [ 1 ]
	do    
	echo " 
	+++++++++++++++++++++++++++++++++++++++++++++++++++++
		       Test TX Power 
	+++++++++++++++++++++++++++++++++++++++++++++++++++++ "
	    
	echo "1.802.11 B "
	echo "2.802.11 G "    		
	echo "3.802.11 N " 
	echo "q.Exit"  		
	echo -n "====> "
	read T
	case "$T" in
	1)
	tx_80211b
	continue
	;;
	2)
	tx_80211g
	continue
	;;
	3)
	tx_80211n
	continue
	;;
	q)
	calibrator wlan0 plt power_mode off
	wifi_unload
	sleep 1
	break
	;;
	*)
	error_type
	;;
	esac
	done  
	;;
    3)
		#       Test RX Sensitivity
	wifi_load
	sleep 1
	calibrator wlan0 plt power_mode on
	sleep 1
		while [ 1 ]
	    do
echo " 
+++++++++++++++++++++++++++++++++++++++++++++++++++++
          Test RX Sensitivity CHANNEL = $CHANNEL
+++++++++++++++++++++++++++++++++++++++++++++++++++++ "

				echo " 1. Set Channel"		   
        			echo " 2. RX Start"
        			echo " 3. RX Stop and Get data"
        			echo " q. Exit"
				echo -n "====> "
				read R
				
				case "$R" in
				1)
				setchannel
				continue
   		  		;;
				2)
				calibrator wlan0 plt tune_channel 0 $CHANNEL
				calibrator wlan0 plt stop_rx_statcs
				sleep 1
				calibrator wlan0 plt reset_rx_statcs
				calibrator wlan0 plt start_rx_statcs
				sleep 1
				echo "Test RX CHANNEL = $CHANNEL Start"
				continue
   		  		;;
    		  		3)
				calibrator wlan0 plt stop_rx_statcs
				sleep 1
				echo "---------Get RX statistics---------"
				calibrator wlan0 plt get_rx_statcs				
				continue
    				;;
    				q)
				calibrator wlan0 plt power_mode off
				sleep 1
				wifi_unload
    				break
    				;;
				*)
	  	 		error_type
				;;
				esac
			done
			;;
   	4)
	bttestmode
	;;
	5)
		throughputtest
	;;
	q)                
                 
        echo "Exit.......";                             
        exit          
    ;;             
    esac

done
echo " "
