mirror_sync
===========

## About
Collection of scripts for synchronization of local mirror.
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

## Usage
* link `.service` and `.timer` to systemd service files.
* Activate `offline_mirror.timer` in your system.

# Sources:
* apt-mirror: [Stifler6996's apt-mirror](https://github.com/Stifler6996/apt-mirror)
* vscode sync: [LOLINTERNETZ's vscodeoffline](https://github.com/LOLINTERNETZ/vscodeoffline)