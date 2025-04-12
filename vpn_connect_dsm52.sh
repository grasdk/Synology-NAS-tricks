#!/bin/sh
LOGFILE="/var/log/vpn.log"

case "$1" in
    start)
		if [ ! -f /usr/local/vpn/vpninfo ]; then
			echo "You need to connect to the VPN manually then cp /tmp/vpnc_current /usr/local/vpn/vpninfo to save the connection info"
			exit 1
		fi
		echo "Getting connection info from last connection..."
		grep -E '^(conf_id|conf_name|proto)=' /usr/local/vpn/vpninfo | sort > /usr/syno/etc/synovpnclient/vpnc_connecting
        # Extract the conf_id from the last connection file
        conf_id=$(grep -E '^conf_id=' /usr/local/vpn/vpninfo | cut -d'=' -f2)
		echo "Starting VPN"
		/usr/syno/bin/synovpnc connect --id="$conf_id" --retry=3 --interval=30
        ;;
    stop)
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
