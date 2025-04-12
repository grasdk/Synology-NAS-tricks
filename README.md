# synology_vpn_scripts
Scripts for Synology DSM to start and stop VPN

## Background

Synology Hyperbackup requires the backup target to be visible to the backup source. If the backup target does not have a public IP or a suitable routing setup, a solution is to let the source and target join the same VPN.

If you can establish such a VPN and have the opportunity to let your synology NASes join it VPN in a secure fashion, where they can see each other, you can use Hyper Backup.

Since Hyper Backup tasks can be scheduled, it would be nice to schedule the NASes' joining and leaving the VPN too, but this capability is not built-in to the task scheduler or the network settings.

## Scripts

The scripts in this repository allow you to have your NAS join and leave the VPN via a script, which you can then schedule in the task scheduler. Use the scripts at your own risk. I take no responsibility for damage or misconfiguration directly or indirectly caused by the use of these scripts.

Both scripts are only tested in a scenario with a single vpn configuration.

### `vpn_connect.sh`

Works for DSM 7.1.1 probably also DSM 6.x. Does not work for DSM 5.x

Requires that you have setup and connected to the VPN before you use the script for the first time.

### `vpn_connect_dsm52.sh`

Works for DSM 5.2

Requires that you connect to the VPN manually, then copy an auto generated file to a specific folder before using the script for the first time.

Instructions
* Create the VPN and connect to it
* SSH into your DSM 5.2
* Create the folder `/usr/local/vpn/`
* Copy the needed file `cp /tmp/vpnc_current /usr/local/vpn/vpninfo`
* Add `vpn_connect_dsm52.sh` to the same folder `/usr/local/vpn/`
* Schedule `/usr/local/vpn/vpn_connect_dsm52.sh start` and `/usr/local/vpn/vpn_connect_dsm52.sh stop` as needed in your task planner.
