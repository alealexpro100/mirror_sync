mirror_sync
===========

## About
Collection of scripts for synchronization of local mirror.
Enables variety of options to enable or disable specific repositories.
Supported mirrors:
* Alpinelinux
* Archlinux
* Debian (+ astralinux, mx-linux, etc.) + software like hw-raid, mongodb, etc.
* Fedora (disabled)
* Voidlinux
* Oraclelinux
* Openwrt
* Tinycore linux
* Cygwin
* Mikrotik

This is personal collection of scripts. That's why commits are not commented.
It is running on LXC container with Debian (512MB RAM, 2 threads, 6TB HDD BTRFS).

## Usage
* link `.service` and `.timer` to systemd service files.
* Activate `offline_mirror.timer` in your system.

# Sources:
* apt-mirror (perl version): [Stifler6996's apt-mirror](https://github.com/Stifler6996/apt-mirror)
