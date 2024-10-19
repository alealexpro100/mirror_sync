#!/bin/bash

echo_d() {
	if [[ "${arch:0:1}" != "#" && "${version:0:1}" != "#" && "${mirror:0:1}" != "#" ]]; then
		echo "$@"
	fi
}

add_d() {
	if [[ "${1:0:1}" != "#" && -n $(echo_d test) ]]; then
		clean="$clean\nclean $1"
	fi
}

arch=''; version=''
mirror=''
s_mirror=''
clean="# CLEAN"

echo '############# config ##################
set base_path    /mnt/mirror/debian/

# set mirror_path  $base_path/mirror
# set skel_path    $base_path/skel
# set var_path     $base_path/var
# set cleanscript  $var_path/clean.sh
# set defaultarch  <running host architecture>

# set postmirror_script $var_path/postmirror.sh
# set run_postmirror 1

set nthreads 20
set _tilde 0
# set limit_rate 25m
#
############# end config ##############

## Type:
### MAIN repo
### UPDATES repo
### BACKPORTS repo
### SECURITY repo
### INSTALLER repo (udeb) '

arch=''; version=''
mirror='http://deb.debian.org/debian'
s_mirror='https://security.debian.org'
d_mirror='http://debug.mirrors.debian.org/debian-debug'
add_d "$mirror"
add_d "$s_mirror"
#add_d "$d_mirror"
echo_d -e "\n# DEBIAN"
for version in '#oldstable' stable testing '#stretch' '#buster' '#bullseye' bookworm trixie sid experimental; do
	echo_d -e "# -- $version"
	for arch in all amd64 i386 arm64 armhf src; do
		components="main non-free contrib"
		if [[ ($version == sid || $version == unstable || $version == experimental || $version == testing) || ($version == bookworm) || ($version == trixie) ]]; then
			components="${components} non-free-firmware"
		fi
		echo_d "deb-$arch $mirror ${version} $components"
		#echo_d "deb-$arch $d_mirror ${version}-debug $components"
		if ! [[ $version == sid || $version == unstable || $version == experimental || $version == trixie ]]; then
			echo_d "deb-$arch $mirror ${version}-updates $components"
			echo_d "deb-$arch $mirror ${version}-proposed-updates $components"
			#echo_d "deb-$arch $d_mirror ${version}-proposed-updates-debug $components"
			echo_d "deb-$arch $mirror ${version}-backports $components"
			#echo_d "deb-$arch $d_mirror ${version}-backports-debug $components"
			if [[ ! ($version == testing || $version == bookworm) ]]; then
				echo_d "deb-$arch $mirror ${version}-backports-sloppy $components"
				#[[ $version == bullseye ]] || echo_d "deb-$arch $d_mirror ${version}-backports-sloppy-debug $components"
			fi
			if [[ $version == oldoldstable || $version == oldstable || $version == stretch || $version == buster ]]; then
				echo_d "deb-$arch $s_mirror ${version}/updates $components"
			else
				echo_d "deb-$arch $s_mirror ${version}-security $components"
			fi
		fi
	done
	echo_d ''
done

arch=''; version=''
mirror='http://fasttrack.debian.net/debian-fasttrack'
add_d "$mirror"
echo_d -e "\n# DEBIAN FASTTRACK"
for version in '#buster-fasttrack' '#buster-backports' '#bullseye-backports-staging' '#bullseye-fasttrack' bookworm-backports-staging bookworm-fasttrack; do
	echo_d -e "# -- $version"
	for arch in all amd64 i386 arm64 armhf src; do
		echo_d "deb-$arch $mirror ${version} main contrib non-free"
	done
	echo_d ''
done

arch=''; version=''
mirror='http://www.deb-multimedia.org'
add_d "$mirror"
echo_d -e "\n# DEBIAN MULTIMEDIA"
for version in '#oldstable' stable testing '#stretch' '#buster' '#bullseye' bookworm trixie sid; do
	echo_d -e "# -- $version"
	for arch in all amd64 i386 arm64 armhf src; do
		echo_d "deb-$arch $mirror ${version} main non-free"
		[[ $version == trixie || $version == testing || $version == sid || $version == experimental || $arch == src ]] || echo_d "deb-$arch $mirror ${version}-backports main"
	done
	echo_d ''
done

arch=''; version=''
mirror='http://dl.winehq.org/wine-builds/debian'
add_d "$mirror"
echo_d -e "\n# WINE"
# Disabled stable and testing because of incorrect Release file size
for version in '#oldstable' '#stable' '#testing' '#stretch' '#buster' '#bullseye' bookworm sid; do
	echo_d -e "# -- $version"
	for arch in all amd64 i386 src; do
		[[ ($version == sid && $arch == src) || ($version == oldstable && $arch == all) || ($version == buster && $arch == all) || ($version == testing && $arch == all) ]] || echo_d "deb-$arch $mirror ${version} main"
	done
	echo_d ''
done

arch=''; version=''
mirror='http://download.webmin.com/download/repository'
add_d "$mirror"
echo_d -e "\n# WEBMIN"
for arch in amd64 i386 arm64 armhf src; do
	echo_d "deb-$arch $mirror sarge contrib"
done

arch=''; version=''
mirror='http://repo.antixlinux.com'
echo_d -e "\n# ANTIX (Based on debian)"
for version in '#stretch' '#buster' '#bullseye' bookworm sid; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror/$version ${version} main nosystemd nonfree"
	done
	add_d "$mirror/$version"
	echo_d ''
done

arch=''; version=''
mirror='http://mxrepo.com/mx/repo'
add_d "$mirror"
echo_d -e "\n# MX-PACKAGES (stable)"
for version in '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} main non-free ahs"
	done
	echo_d ''
done
echo_d "ignore_errors $mirror pool/main/b/bash-config/bash-config-dbgsym_24.01.02_amd64.deb"
echo_d "ignore_errors $mirror pool/main/b/bash-config/bash-config-dbgsym_24.01.02_i386.deb"

arch=''; version=''
mirror='http://liquorix.net/debian'
add_d "$mirror"
echo_d -e "\n# ZEN KERNEL (liquorix)"
for version in '#oldstable' stable testing '#stretch' '#buster' '#bullseye' bookworm trixie sid; do
	echo_d -e "# -- $version"
	for arch in amd64 '#i386' src; do
		echo_d "deb-$arch $mirror ${version} main"
	done
	echo_d ''
done

mirror='http://hwraid.le-vert.net/debian'
add_d "$mirror"
echo_d -e "\n# HWRAID repo"
for version in '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} main"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://deb.opera.com/opera'
add_d "$mirror"
echo_d -e "\n# OPERA"
for version in stable testing sid; do
	echo_d -e "# -- $version"
	for arch in amd64 i386; do
		echo_d "deb-$arch $mirror ${version} non-free"
	done
done

arch=''; version=''
mirror='http://download.virtualbox.org/virtualbox/debian'
add_d "$mirror"
echo_d -e "\n# VIRTUALBOX"
for version in '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	for arch in amd64 i386; do
		echo_d "deb-$arch $mirror ${version} contrib non-free"
	done
done

arch=''; version=''
mirror='http://download.onlyoffice.com/repo/debian'
add_d "$mirror"
echo_d -e "\n# ONLYOFFICE"
for arch in amd64 i386; do
	echo_d "deb-$arch $mirror squeeze main"
done

arch=''; version=''
mirror='#http://http.kali.org/kali'
add_d "$mirror"
echo_d -e "\n# KALI LINUX"
for version in kali-rolling '#kali-dev'; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 arm64 armhf src; do
		echo_d "deb-$arch $mirror ${version} main contrib non-free"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://raspbian.raspberrypi.org/raspbian'
add_d "$mirror"
echo_d -e "\n# RASPBIAN"
for version in '#oldstable' stable testing '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	for arch in armhf src; do
		echo_d "deb-$arch $mirror ${version} main contrib non-free rpi"
	done
	echo_d ''
done

arch=''; version=''
mirror='http://apt.armbian.com'
add_d "$mirror"
echo_d -e "\n# ARMBIAN"
for version in '#focal' '#buster' '#bullseye' bookworm sid; do
	echo_d -e "# -- $version"
	for arch in arm64 armhf; do
		echo_d "deb-$arch $mirror ${version} main $version-utils $version-desktop"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://archive.ubuntu.com/ubuntu'
s_mirror='#http://security.ubuntu.com/ubuntu'
add_d "$mirror"
add_d "$s_mirror"
echo_d -e "\n# UBUNTU"
for version in '#xenial' '#focal' jammy; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-backports main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-proposed main restricted universe multiverse"
		echo_d "deb-$arch $s_mirror ${version}-security main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-updates main restricted universe multiverse"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://archive.canonical.com/ubuntu'
add_d "$mirror"
echo_d -e "\n# CANONICAL PARTNER"
for version in '#xenial' '#focal' jammy; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} partner"
		echo_d "deb-$arch $mirror ${version}-proposed partner"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://ports.ubuntu.com'
add_d "$mirror"
echo_d -e "\n# UBUNTU PORTS"
for version in '#xenial' '#focal' jammy; do
	echo_d -e "# -- $version"
	for arch in arm64 '#armhf' src; do
		echo_d "deb-$arch $mirror ${version} main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-security main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-updates main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-backports main restricted universe multiverse"
	done
	echo_d ''
done

#For astra please see http://wiki.astralinux.ru/pages/viewpage.action?pageId=158598882.

arch=''; version=''
mirror='http://dl.astralinux.ru/astra/frozen'
add_d "$mirror"
echo_d -e "\n# ASTRALINUX SE"
for version in "1.7.5/uu/1"; do
	for arch in amd64; do
		echo_d "deb-$arch $mirror/1.7_x86-64/${version}/repository-main 1.7_x86-64 main contrib non-free"
		echo_d "deb-$arch $mirror/1.7_x86-64/${version}/repository-update 1.7_x86-64 main contrib non-free"
		echo_d "deb-$arch $mirror/1.7_x86-64/${version}/repository-base 1.7_x86-64 main contrib non-free"
		echo_d "deb-$arch $mirror/1.7_x86-64/${version}/repository-extended 1.7_x86-64 main contrib non-free astra-ce"
	done
done
echo_d ''

arch=''; version=''
mirror='http://download.proxmox.com/debian/pve'
add_d "$mirror"
echo_d -e "\n# PROXMOX"
for version in '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	echo_d "deb-amd64 $mirror ${version} pve-no-subscription pvetest"
	echo_d ''
done

arch=''; version=''
mirror='#http://repo.mongodb.org/apt/debian'
add_d "$mirror"
echo_d -e "\n# MONGODB CE (debian)"
for version in '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	for arch in amd64 arm64; do
		echo_d "deb-$arch $mirror ${version}/mongodb-org/5.0 main"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://repo.radeon.com/rocm/apt/debian'
add_d "$mirror"
echo_d -e "\n# AMD ROCM"
echo_d "deb-amd64 $mirror ubuntu main proprietary"
echo_d ''

arch=''; version=''
mirror='#http://repo.radeon.com/amdgpu/latest/ubuntu'
add_d "$mirror"
echo_d -e "\n# AMDGPU"
for version in focal jammy; do
	echo_d -e "# -- $version"
	for arch in i386 amd64 src; do
		echo_d "deb-$arch $mirror ${version} main proprietary"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://repo.radeon.com/amdvlk/apt/debian'
add_d "$mirror"
echo_d -e "\n# AMDVLK"
for arch in i386 amd64; do
	echo_d "deb-$arch $mirror bionic main"
done

arch=''; version=''
mirror='#http://deb.torproject.org/torproject.org'
add_d "$mirror"
echo_d -e "\n# TOR"
for version in '#stretch' '#buster' '#bullseye' bookworm trixie sid; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 arm64; do
		echo_d "deb-$arch $mirror ${version} contrib non-free"
	done
done

arch=''; version=''
mirror='#http://archive.turnkeylinux.org/debian'
add_d "$mirror"
echo_d -e "\n# TURNKEY"
for version in '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	for arch in all amd64; do
		echo_d "deb-$arch $mirror ${version} main"
		echo_d "deb-$arch $mirror ${version}-security main"
		echo_d "deb-$arch $mirror ${version}-testing main"
	done
	echo_d ''
done

arch=''; version=''
mirror='#http://packages.microsoft.com/repos/vscode'
add_d "$mirror"
echo_d -e "\n# VSCODE"
echo_d "deb-amd64 $mirror stable main"

arch=''; version=''
mirror='http://repo.saltproject.io/salt/py3/debian/12/amd64/latest'
add_d "$mirror"
echo_d -e "\n# SALT (latest)"
echo_d "deb-amd64 $mirror bookworm main"

arch=''; version=''
mirror='#http://packages.microsoft.com/repos/ms-teams'
add_d "$mirror"
echo_d -e "\n# MS TEAMS"
for arch in amd64 arm64; do
	echo_d "deb-$arch $mirror stable main"
done

arch=''; version=''
mirror='#http://packages.microsoft.com/repos/code'
add_d "$mirror"
echo_d -e "\n# MS CODE"
for arch in amd64 arm64 armhf; do
	echo_d "deb-$arch $mirror stable main"
done

arch=''; version=''
mirror='#http://packages.microsoft.com/debian/12/prod'
add_d "$mirror"
echo_d -e "\n# MS PROD DEBIAN 12"
for version in bookworm insiders-fast insiders-slow nightly testing; do
	echo_d -e "# -- $version"
	for arch in amd64 arm64 armhf; do
		echo_d "deb-$arch $mirror ${version} main"
	done
done

arch=''; version=''
mirror='#http://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs'
add_d "$mirror"
echo_d -e "\n# VSCODIUM"
for arch in amd64 i386 arm64 armhf; do
	echo_d "deb-$arch $mirror vscodium main"
done

arch=''; version=''
mirror='http://download.docker.com/linux/debian'
add_d "$mirror"
echo_d -e "\n# Docker CE"
for version in '#stretch' "#buster" '#bullseye'; do
	echo_d -e "# -- $version"
	for arch in amd64 arm64 armhf '#ppc64el'; do
		echo_d "deb-$arch $mirror ${version} stable test nightly"
	done
done

arch=''; version=''
mirror='http://nginx.org/packages/debian'
add_d "$mirror"
echo_d -e "\n# NGINX"
for version in '#stretch' '#buster' '#bullseye' bookworm; do
	echo_d -e "# -- $version"
	for arch in amd64 arm64; do
		echo_d "deb-$arch $mirror ${version} nginx"
	done
done

arch=''; version=''
mirror='http://download.opensuse.org/repositories/home:/Hezekiah/Debian_10'
add_d "$mirror"
echo_d -e "\n# samba-ad-dc"
for arch in amd64 src; do
	echo_d "deb-$arch $mirror ./"
done

echo -e "\n$clean"
