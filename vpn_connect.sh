#!/bin/sh
# VPN static route fix for Synology DSM
VPN_GATEWAY="192.168.250.1"
VPN_SUBNET="192.168.250.0/24"
LOGFILE="/var/log/vpn.log"

case "$1" in
    start)
		if [ ! -f /usr/syno/etc/synovpnclient/vpnc_last_connect ]; then
			echo "You need to connect to and disconnect from the VPN manually once before using this script."
			exit 1
		fi
		echo "Getting connection info from last connection..."
		grep -E '^(conf_id|conf_name|proto)=' /usr/syno/etc/synovpnclient/vpnc_last_connect | sort > /usr/syno/etc/synovpnclient/vpnc_connecting
        # Extract the conf_id from the last connection file
        conf_id=$(grep -E '^conf_id=' /usr/syno/etc/synovpnclient/vpnc_last_connect | cut -d'=' -f2)
		echo "Starting VPN"
		/usr/syno/bin/synovpnc connect --id="$conf_id" --retry=3 --interval=30
        echo "Waiting for VPN to become active..."
        while ! ping -c 1 -W 1 $VPN_GATEWAY >/dev/null 2>&1; do
            sleep 5  # Wait 5 seconds before checking again
        done
        echo "VPN is active, adding static route..."
        ip route add $VPN_SUBNET via $VPN_GATEWAY
        ;;
    stop)
        echo "Removing static route for VPN..."
        ip route del $VPN_SUBNET via $VPN_GATEWAY
		touch $LOGFILE
		/usr/syno/bin/synovpnc get_conn >>$LOGFILE
		/usr/syno/bin/synovpnc kill_client
		/usr/syno/bin/synovpnc kill_client
		/usr/syno/bin/synovpnc clear
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit 0
