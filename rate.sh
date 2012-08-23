#! /system/bin/sh
# Program:
# Program creates by Vane and it is for TX only.
# History:
# 2012/03/20	Vane	Jorjin release

POWER="20000"
SHOW_PWR=""
REL_RATE=""
RATE="not_set!!"
REL_BAND=""
BAND="not_set!!"
CHANNEL=$TEMP

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
#		WIFI set power
#***********************************************************
power_fun(){
read -p "Please refer example type (Ex:10000)
Please type Power :
===>" PW
if [ "$PW" -gt 20000 -o "$PW" -lt 1000 ]; then
echo "You type wrong Power!! 
Power set to default!!"
POWER=20000
else
POWER=$PW
fi
}

#***********************************************************
#		WIFI set band
#***********************************************************
bandrate_fun(){
echo -n "++++++++++++++++++++++++++++++++++++++++++++++++++
		WIFI set band
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - 11B

2) - 11G

3) - 11N

Q) - Quit

Please select Band :
===>"
read BAND_SELECT
busybox clear
case "$BAND_SELECT" in
1) #11B: 0
	REL_BAND=0
	BAND=802.11B
	read -p "++++++++++++++++++++++++++++++++++++++++++++++++++
		802.11B
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - 1M
 
2) - 2M

3) - 5.5M

4) - 11M

Q) - Back to Previous

Please select rate
===>" RT
		case $RT in
			1)
			RATE=1M
			REL_RATE=0x00000001
			;;
			2)
			RATE=2M
			REL_RATE=0x00000002
			;;
			3)
			RATE=5.5M
			REL_RATE=0x00000004
			;;
			4)
			RATE=11M
			REL_RATE=0x00000020
			;;
			q|Q)
			busybox clear
			REL_RATE=""
			RATE="not_set!!"
			REL_BAND=" "
			BAND="not_set!!"
			;;
			*)
			error_type
			;;
		esac
	unset $RT
	busybox clear
	continue;;

2) #11G: 4
	REL_BAND=4
	BAND=802.11G
	read -p "++++++++++++++++++++++++++++++++++++++++++++++++++
		802.11G
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - 6M

2) - 9M

3) - 12M

4) - 18M

5) - 24M

6) - 36M

7) - 48M

8) - 54M

Q) - Back to Previous

Please select rate
===>" RT
		case $RT in
			1)
			RATE=6M
			REL_RATE=0x00000008
			;;
			2)
			RATE=9M
			REL_RATE=0x00000010
			;;
			3)
			RATE=12M
			REL_RATE=0x00000040
			;;
			4)
			RATE=18M
			REL_RATE=0x00000080
			;;
			5)
			RATE=24M
			REL_RATE=0x00000200
			;;
			6)
			RATE=36M
			REL_RATE=0x00000400
			;;
			7)
			RATE=48M
			REL_RATE=0x00000800
			;;
			8)
			RATE=54M
			REL_RATE=0x00001000
			;;
			q|Q)
			busybox clear
			REL_RATE=""
			RATE="not_set!!"
			REL_BAND=" "
			BAND="not_set!!"
			;;
			*)
			error_type
			;;
		esac
	unset $RT
	busybox clear
	continue;;

3) #11N: 6
	REL_BAND=6
	BAND=802.11N
	read -p "++++++++++++++++++++++++++++++++++++++++++++++++++
		802.11N
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - MCS0

2) - MCS1

3) - MCS2

4) - MCS3

5) - MCS4

6) - MCS5

7) - MCS6

8) - MCS7

Q)Back to Previous

Please select rate
===>" RT
		case $RT in
			1)
			RATE=MCS0
			REL_RATE=0x00002000
			;;
			2)
			RATE=MCS1
			REL_RATE=0x00004000
			;;
			3)
			RATE=MCS2
			REL_RATE=0x00008000
			;;
			4)
			RATE=MCS3
			REL_RATE=0x00010000
			;;
			5)
			RATE=MCS4
			REL_RATE=0x00020000
			;;
			6)
			RATE=MCS5
			REL_RATE=0x00040000
			;;
			7)
			RATE=MCS6
			REL_RATE=0x00080000
			;;
			8)
			RATE=MCS7
			REL_RATE=0x00100000
			;;
			q|Q)
			REL_RATE=""
			RATE="not_set!!"
			REL_BAND=" "
			BAND="not_set!!"
			busybox clear
			;;
			*)
			error_type
			;;
		esac
	unset $RT
	busybox clear
	continue;;

q|Q)
	REL_RATE=""
	RATE="not_set!!"
	REL_BAND=" "
	BAND="not_set!!"
	busybox clear
;;
*)
	error_type
;;
esac
}


#-------------------------------------- Main --------------------------------------
while [ 1 ] 
do
SHOW_PWR=$(( $POWER / 1000 ))
echo "++++++++++++++++++++++++++++++++++++++++++++++++++
               TX POWER MENU 
CHANNEL:	$CHANNEL 
Band:		$BAND 
Rate:		$RATE 
Power:		$SHOW_PWR dBm
++++++++++++++++++++++++++++++++++++++++++++++++++
1) Set Power

2) Select Band & Rate

3) Start Test

Q) Quit to WIFI MENU

====>"
read TX_OPT
	case "$TX_OPT" in
	1)
		busybox clear
		power_fun
		continue
		;;

	2)
		busybox clear
		bandrate_fun
		continue
		;;

	3)
		busybox clear
		sleep 1 #don't del it
		calibrator wlan0 plt tx_stop
		sleep 1
		if [ $RATE == "not_set!!" ]; then
			break
			echo "Type ERROR!! Please try again!! "
		else
			echo "Runing Tx Power "			#calibrator wlan0 plt tx_cont 20 0x00001000 1000 0 20000 10000 3 1 0 4 0 1 1 1 DE:AD:BE:EF:00:00
			calibrator wlan0 plt tx_cont 20 $REL_RATE 1000 0 $POWER 10000 3 1 0 $REL_BAND 0 1 1 1 DE:AD:BE:EF:00:00
			sleep 1
				while [ 1 ]
				do
				read -p "Pass T to Stop TX..." PAUSE
						if [ $PAUSE == "T"  ]; then
						calibrator wlan0 plt tx_stop
							echo "Stop Runing Tx Power "
							break
						else
							echo "Type ERROR!! Please try again!! "
						fi		
				done
		fi
			continue
		;;
	q|Q)
		calibrator wlan0 plt tx_stop
		echo " Stop Runing Tx Power "
		#sleep 2
		busybox clear
        	exit
    		;;
	esac
done

