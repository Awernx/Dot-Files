# 🔨 Svalbard on Mjolnir
Svalbard [- Interesting name! ℹ️](https://en.wikipedia.org/wiki/Svalbard_Global_Seed_Vault)

## Mounting SSD with FSTAB

The external Svalbard SSD  must be mounted adding the following FSTAB entry in the ```/etc/fstab``` file.

```bash
/dev/sdb2	/mnt/svalbard 	ntfs	defaults    0    0
```

> The current mjolnir **FSTAB** file is [available here for quick reference](./etc/fstab.bak)


## Samba to share Svalbard across the network
[**Samba**](https://www.samba.org) enables file sharing across different operating systems over a network. [Install and set up Samba](https://ubuntu.com/tutorials/install-and-configure-samba#1-overview) to share Svalbard with the network.

> [Samba configuration file](./etc/samba/smb.conf)

## Self-discovery of Svalbard across the network

To enable self discovery of Svalbard across the local network, the following must be installed:

### Avahi
[**Avahi**](https://github.com/avahi/avahi) enables macOS and iOS devices discover Svalbard. The Avahi mDNS/DNS-SD daemon implements Apple's Zeroconf architecture (also known as "Rendezvous" or "Bonjour"). 
> [Avahi configuration file](./etc/avahi/avahi-daemon.conf)

### WSDD 
[**wsdd**](https://github.com/christgau/wsdd) enables Windows devices discover Svalbard.
> [wsdd systemd service file](./etc/systemd/system/wsdd.service)
