#!/bin/bash
set -euo pipefail

BLOCKLIST_URL='https://list.iblocklist.com/?list=bt_level1&fileformat=p2p&archiveformat=gz'
BLOCKLIST_FILE=/var/packages/DownloadStation/etc/download/blocklists/level1

echo "Clean old blocklist"
rm -f $(dirname $BLOCKLIST_FILE)/*

echo "Download new blocklist"
curl -sSLf --retry 10 --retry-delay 60 --max-time 30 "$BLOCKLIST_URL" \
        | gzip -cd - \
        | sed -e '/^\s*#/d' -e '/^\s*$/d' \
        > $BLOCKLIST_FILE

# patch configuration & service files that might be overwritten after a package update:
# - enable blocklists in transmissiond config file
# - prevent this config file to be deleted by the service's startup script
echo "Patch service files"
sed -i /var/packages/DownloadStation/etc/download/settings.json \
        -e 's/\(^\s*"blocklist-enabled"\s*:\)[^,]*/\1 true/' \
        -e 's/\(^\s*"blocklist-url"\s*:\)[^,]*/\1 ""/'
sed -i /var/packages/DownloadStation/scripts/start-stop-status \
        -e 's|\(^\s*rm .\+/settings.json\s*$\)|#\1|'

echo "Restart DownloadStation"
#synoservicectl --restart pkgctl-DownloadStation
/var/packages/DownloadStation/target/scripts/S25download.sh restart

echo "Verify that the blocklist file was loaded by transmissiond"
sleep 10  # wait for transmissiond to finish starting up
[ -s "$BLOCKLIST_FILE".bin ] \
    || { echo "Missing bin file: blocklist was not loaded by transmissiond"; exit 1; }
# transmissiond logfile: /var/services/download/transmissiond.log
