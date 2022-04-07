#!/bin/bash

echo_d() {
	if [[ "${arch:0:1}" != "#" && "${version:0:1}" != "#" ]]; then
		echo "$@"
	fi
}

echo '############# config ##################
set base_path    /mnt/mirror/debian/

# set mirror_path  $base_path/mirror
# set skel_path    $base_path/skel
# set var_path     $base_path/var
# set cleanscript $var_path/clean.sh
# set defaultarch  <running host architecture>

set checksums = 1

# set postmirror_script $var_path/postmirror.sh
set run_postmirror 0

set nthreads     20
set _tilde 0
#
############# end config ##############

## Type:
### MAIN repo
### UPDATES repo
### BACKPORTS repo
### SECURITY repo
### INSTALLER repo (udeb) '

arch=''; version=''
mirror='https://deb.debian.org/debian'
s_mirror='http://security.debian.org'
clean="$clean\nclean $mirror\nclean $s_mirror"
echo_d -e "\n# DEBIAN"
for version in oldstable stable '#testing' '#stretch' buster bullseye sid; do
	echo_d -e "# -- $version"
	for arch in all amd64 i386 arm64 armhf src; do
		echo_d "deb-$arch $mirror ${version} main non-free contrib"
		[[ $version == sid ]] || echo_d "deb-$arch $mirror ${version}-updates main non-free contrib"
		[[ $version == sid ]] || echo_d "deb-$arch $mirror ${version}-backports main non-free contrib"
		if [[ $version == oldoldstable || $version == oldstable || $version == stretch || $version == buster ]]; then
			[[ $version == sid ]] || echo_d "deb-$arch $s_mirror ${version}/updates main non-free contrib"
		else
			[[ $version == sid ]] || echo_d "deb-$arch $s_mirror ${version}-security main non-free contrib"
		fi
	done
	echo_d ''
done

arch=''; version=''
mirror='https://www.deb-multimedia.org'
clean="$clean\nclean $mirror"
echo_d -e "\n# DEBIAN MULTIMEDIA"
for version in oldstable stable '#testing' '#stretch' buster bullseye sid; do
	echo_d -e "# -- $version"
	for arch in all amd64 i386 arm64 armhf src; do
		echo_d "deb-$arch $mirror ${version} main non-free"
		[[ $version == testing || $version == sid || $arch == src ]] || echo_d "deb-$arch $mirror ${version}-backports main"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://dl.winehq.org/wine-builds/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# WINE"
for version in oldstable stable '#testing' '#stretch' buster bullseye sid; do
	echo_d -e "# -- $version"
	for arch in all amd64 i386 src; do
		[[ ($version == sid && $arch == src) || ($version == oldstable && $arch == all) || ($version == buster && $arch == all) ]] || echo_d "deb-$arch $mirror ${version} main"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://download.webmin.com/download/repository'
clean="$clean\nclean $mirror"
echo_d -e "\n# WEBMIN"
for arch in amd64 i386 arm64 armhf src; do
	echo_d "deb-$arch $mirror sarge contrib"
done

arch=''; version=''
mirror='https://repo.antixlinux.com'
echo_d -e "\n# ANTIX (Based on debian)"
for version in '#stretch' buster bullseye sid; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror/$version ${version} main nosystemd nonfree"
	done
	clean="$clean\nclean $mirror/$version"
	echo_d ''
done

arch=''; version=''
mirror='http://mxrepo.com/mx/repo'
clean="$clean\nclean $mirror"
echo_d -e "\n# MX-PACKAGES (stable)"
for version in '#stretch' buster bullseye; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} main non-free ahs"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://liquorix.net/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# ZEN KERNEL (liquorix)"
for version in oldstable stable '#testing' '#stretch' buster bullseye sid; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} main"
	done
	echo_d ''
done

mirror='http://hwraid.le-vert.net/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# HWRAID repo"
for version in '#stretch' buster bullseye; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} main"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://deb.opera.com/opera'
clean="$clean\nclean $mirror"
echo_d -e "\n# OPERA"
for version in stable testing sid; do
	echo_d -e "# -- $version"
	for arch in amd64 i386; do
		echo_d "deb-$arch $mirror ${version} non-free"
	done
done

arch=''; version=''
mirror='https://download.virtualbox.org/virtualbox/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# VIRTUALBOX"
for version in '#stretch' buster bullseye; do
	echo_d -e "# -- $version"
	for arch in amd64 i386; do
		echo_d "deb-$arch $mirror ${version} contrib non-free"
	done
done

arch=''; version=''
mirror='https://download.onlyoffice.com/repo/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# ONLYOFFICE"
for arch in amd64 i386; do
	echo_d "deb-$arch $mirror squeeze main"
done

arch=''; version=''
mirror='https://http.kali.org/kali'
clean="$clean\nclean $mirror"
echo_d -e "\n# KALI LINUX"
for version in kali-rolling '#kali-dev'; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 arm64 armhf src; do
		echo_d "deb-$arch $mirror ${version} main contrib non-free"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://raspbian.raspberrypi.org/raspbian'
clean="$clean\nclean $mirror"
echo_d -e "\n# RASPBIAN"
for version in '#oldstable' '#stable' '#testing' '#stretch' '#buster' '#bullseye' '#sid'; do
	echo_d -e "# -- $version"
	for arch in armhf src; do
		echo_d "deb-$arch $mirror ${version} main contrib non-free rpi"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://apt.armbian.com'
clean="$clean\nclean $mirror"
echo_d -e "\n# ARMBIAN"
for version in '#focal' buster bullseye sid; do
	echo_d -e "# -- $version"
	for arch in arm64 armhf; do
		echo_d "deb-$arch $mirror ${version} main $version-utils $version-desktop"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://archive.ubuntu.com/ubuntu'
s_mirror='https://security.ubuntu.com/ubuntu'
#clean="$clean\nclean $mirror\nclean $s_mirror"
echo_d -e "\n# UBUNTU"
for version in '#xenial' '#focal'; do
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
mirror='https://archive.canonical.com/ubuntu'
#clean="$clean\nclean $mirror"
echo_d -e "\n# CANONICAL PARTNER"
for version in '#xenial' '#focal'; do
	echo_d -e "# -- $version"
	for arch in amd64 i386 src; do
		echo_d "deb-$arch $mirror ${version} partner"
		echo_d "deb-$arch $mirror ${version}-proposed partner"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://ports.ubuntu.com'
#clean="$clean\nclean $mirror"
echo_d -e "\n# UBUNTU PORTS"
for version in '#xenial' '#focal'; do
	echo_d -e "# -- $version"
	for arch in arm64 '#armhf' src; do
		echo_d "deb-$arch $mirror ${version} main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-security main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-updates main restricted universe multiverse"
		echo_d "deb-$arch $mirror ${version}-backports main restricted universe multiverse"
	done
	echo_d ''
done


arch=''; version=''
mirror='http://download.proxmox.com/debian/pve'
clean="$clean\nclean $mirror"
echo_d -e "\n# PROXMOX"
for version in '#stretch' buster bullseye; do
	echo_d -e "# -- $version"
	echo_d "deb-amd64 $mirror ${version} pve-no-subscription pvetest"
	echo_d ''
done

arch=''; version=''
mirror='http://repo.mongodb.org/apt/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# MONGODB CE (debian)"
for version in '#stretch' buster; do
	echo_d -e "# -- $version"
	for arch in amd64 arm64; do
		echo_d "deb-$arch $mirror ${version}/mongodb-org/5.0 main"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://repo.radeon.com/rocm/apt/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# AMD ROCM"
echo_d "deb-amd64 $mirror ubuntu main proprietary"
echo_d ''

arch=''; version=''
mirror='https://repo.radeon.com/amdgpu/latest/ubuntu'
clean="$clean\nclean $mirror"
echo_d -e "\n# AMDGPU"
for version in bionic focal; do
	echo_d -e "# -- $version"
	for arch in i386 amd64 src; do
		echo_d "deb-$arch $mirror ${version} main proprietary"
	done
	echo_d ''
done

arch=''; version=''
mirror='https://repo.radeon.com/amdvlk/apt/debian'
clean="$clean\nclean $mirror"
echo_d -e "\n# AMDVLK"
for arch in i386 amd64; do
	echo_d "deb-$arch $mirror bionic main"
done

echo -e "\n$clean"
