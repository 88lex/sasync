#!/bin/bash

#I ask the questions around here mister!

RCLONECONFIGFILE=$(whiptail --inputbox "Location of your rclone.conf file\nNOTE: Needs to have one google remote configured" 8 78 "$HOME/.config/rclone/rclone.conf" --title "SMOUNT++" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Reading $RCLONECONFIGFILE"
else
    echo "You Cancled, Bailing!"
    exit
fi

OAUTHTOKEN=$(awk -F "=" '/token/ {print $2}' $RCLONECONFIGFILE | grep "Bearer" | head -n 1 | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

#OAUTHTOKEN=$(awk -F "=" '/token/ {print $2}' $RCLONECONFIGFILE | grep "Bearer" | head -n 1 | python3 -c "import sys, json; print(json.load(sys.stdin)['refresh_token'])")

CLIENTID=$(awk -F "=" '/client_id/ {print $2}' $RCLONECONFIGFILE | head -n 1 |tr -d '\n')
CLIENTSECRET=$(awk -F "=" '/client_secret/ {print $2}' $RCLONECONFIGFILE | head -n 1 |tr -d '\n')
CLIENTTOKEN=$(awk -F "=" '/token/ {print $2}' $RCLONECONFIGFILE | head -n 1 |tr -d '\n')

if [ -z "$CLIENTTOKEN" ]
then
whiptail --title "SAMOUNT++" --msgbox "Unable to find any client token in rclone.conf, Please make sure the config is there, you need to configure one google remote before you can continue" 20 78
echo "Unable to find any client token in rclone.conf, Please make sure the config is there, you need to configure one google remote before you can continue"
exit
fi
if [ -z "$CLIENTSECRET" ]
then
echo "Unable to find any client_secret in rclone.conf"
exit
fi
if [ -z "$CLIENTID" ]
then
echo "Unable to find any client_id in rclone.conf"
exit
fi



echo Getting List of Team Drives using $OAUTHTOKEN
DRIVEJSON=`curl 'https://www.googleapis.com/drive/v3/drives?pageSize=100' --header "Authorization: Bearer $OAUTHTOKEN" --header 'Accept: application/json' --compressed`
DRIVEIDS=`echo "$DRIVEJSON" | python -m json.tool | grep '"id":' | cut -d':' -f2 | sed 's/[^a-z  A-Z0-9_-]//g'`
DRIVENAMES=`echo "$DRIVEJSON" | python -m json.tool | grep '"name":' | cut -d':' -f2 | sed 's/[^a-z  A-Z0-9_-]//g'`

if [ -z "$DRIVEIDS" ]
then
whiptail --title "SAMOUNT++" --msgbox "Unable to find any Team Drive IDS\nTry refreshing your token? just run: rclone ls google:/" 8 78
echo "Unable to find any Team Drive IDS"
echo "Try refreshing your token? just run: rclone ls google:/"
echo -e "$DRIVEJSON"
exit
fi

if [ -z "$DRIVENAMES" ]
then
whiptail --title "SAMOUNT++" --msgbox "Unable to find any Team Drive IDS\nTry refreshing your token? just run: rclone ls google:/" 8 78
echo "Unable to find any Team Drive Names"
echo -e "$DRIVEJSON"
exit
fi


readarray DRIVENAMESARRAY <<<"$DRIVENAMES"
readarray DRIVEIDSARRAY <<<"$DRIVEIDS"

RCLONECONFIGFILEWRITE=$(whiptail --inputbox "File to write your new config to\nNOTE:This will completly replace your config, add a google: remote and all the teamdrive remotes" 8 78 "$HOME/.config/rclone/rclone.conf" --title "SMOUNT++" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Writing $RCLONECONFIGFILE"
else
    echo "You Cancled, Bailing!"
    exit
fi


echo "
[google]
type = drive
scope = drive
server_side_across_configs = true
client_id = $CLIENTID
client_secret = $CLIENTSECRET
token = $CLIENTTOKEN
">$RCLONECONFIGFILEWRITE

count=0
for i in "${DRIVENAMESARRAY[@]}"
do
CURRENTNAME=`echo "$i" |tr -d '\n' | tr -d ' '`
CURRENTID=`echo ${DRIVEIDSARRAY[$count]} | tr -d '\n' | tr -d ' '`
echo $CURRENTNAME - $CURRENTID
echo "
[$CURRENTNAME]
type = drive
scope = drive
server_side_across_configs = true
team_drive = $CURRENTID
client_id = $CLIENTID
client_secret = $CLIENTSECRET
token = $CLIENTTOKEN
">>$RCLONECONFIGFILEWRITE

(( count++ ))
done
