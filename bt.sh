#!/system/bin/sh
# Program:
# Program creates by Vane and it is BT Test Mode only.
# History:
# 2012/03/23	Vane	Jorjin release

FOOLPROOF=0
#***********************************************************
#		Error type
#***********************************************************
error_type(){
	echo "
Error type, Please try again!!!!!"
sleep 1
busybox clear
}

#-------------------------------------- Main --------------------------------------

while [ 1 ]
    do
echo " 
++++++++++++++++++++++++++++++++++++++++++++++++++
               MAIN NENU -> BT NENU
++++++++++++++++++++++++++++++++++++++++++++++++++
1) - Entering BT Test Mode

2) - Disable BT

Q) - Exit"
echo -n "====> "
read BT
case "$BT" in
	1)
		if [ $FOOLPROOF == "0" ]; then
		bttest enable
		sleep 1
		hcitool cmd 0x3f 0x10c 0x00 0x00 0x00 0xff 0xff 0xff 0xff 0x64 #make BT don't enter deep sleep mode.
		hcitool cmd 0x03 0x1a 0x03
		hcitool cmd 0x03 0x05 0x02 0x00 0x03
		hcitool cmd 0x06 0x03
		sleep 1
		echo "----------------------------------------"
		echo "-  BlueTooth Test Mode Start !!!	 -"
		echo "----------------------------------------"
		#todo : if I enable BT twice, then make user can't type the second times.
		FOOLPROOF=1
		else
		echo " Sorry !! You can't Enable BT twice!! "
		fi
		continue
		;;

	2)
		bttest disable
		sleep 1
		echo "----------------------------------------"
		echo "-  BlueTooth Test Mode Disable !!!     -"
		echo "----------------------------------------"
		FOOLPROOF=0
		continue
		;;

	q|Q)
		bttest disable
		echo " BlueTooth is closing now !!! "
		sleep 1
		break
		;;

	*)
		error_type
		;;
esac
done


