# Tool installation

Even though it is not encouraged by synology, enabling SSH and accessing your NAS via a terminal has some nice benefits.

For example you can move files from one share to another in an instant, because you're accessing the disk directly.

`mv /volume1/share1/bigfile1 /volume2/share2/` will be almost instant, whereas the equivalent copy via NFS or SMB will transfer everything over the network.

You can also do other things and have tools help with that. So here is how to install them

## Midnight commander

I find Midnight Commander useful to quickly browse and find what I need and use it to copy and move stuff.

To install it, along with some other tools, follow the guide here: https://think.unblog.ch/en/how-to-install-midnight-commander-on-synology-nas/

Shortly put:

1. Open package manager
2. Check Settings -> General -> Trust Level -> Synology Inc. and trusted publishers
3. Go to Settings -> Package Sourcers and click "Add"
   - Enter 'SynoCommunity' under name
   - Enter 'https://packages.synocommunity.com/' under Location
   - Click "Ok"
4. Go to "All packages"
5. Find `SynoCli File Tools` and click install.

## Exiftool

There used to be a community package for exiftool as well, but it has been discontinued.

Instead one can download and install it manually. I made an [Ansible Playbook](install_exiftool.yml) and a [hosts-file](hosts.yml) for this.

```
ansible-playbook -i hosts.yml install_exiftool.yml -u <your admin-user on the nas> --ask-pass -b --ask-become-pass
```