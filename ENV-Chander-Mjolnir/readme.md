# 🔨 Mjolnir
An [Ubuntu Server](https://ubuntu.com/download/server) based home server that hosts Svalbard on BlissHighway

### Svalbard [ℹ️](https://en.wikipedia.org/wiki/Svalbard_Global_Seed_Vault)

#### Mounting [SSD](https://en.wikipedia.org/wiki/Solid-state_drive)

The external Svalbard SSD  must be mounted using the following FSTAB entry  

```
    /dev/sdb2	/mnt/svalbard 	ntfs	defaults    0    0
```

> The current mjolnir **FSTAB** file is [available here for quick reference](./etc/fstab)

#### Samba share

A Samba file server enables file sharing across different operating systems over a network. [Install and set up Samba](https://ubuntu.com/tutorials/install-and-configure-samba#1-overview) to share Svalbard with the network.

> [Samba configuration file](./etc/samba/smb.conf)

#### Enabling self-discovery of Svalbard

To enable self discovery of Svalbard across the network, the following must be installed:

- [**avahi**](https://github.com/avahi/avahi) for macOS: The Avahi mDNS/DNS-SD daemon implements Apple's Zeroconf architecture (also known as "Rendezvous" or "Bonjour"). 
    > [Avahi configuration file](./etc/avahi/avahi-daemon.conf)

- [**wsdd**](https://github.com/christgau/wsdd) for Windows: WS-Discovery is the way Windows discovers other Windows boxes in the network
    > [wsdd systemd service file](./etc/systemd/system/wsdd.service)
