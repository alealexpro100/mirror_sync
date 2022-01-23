#!/bin/bash
###############################################################
### Mirror sync script
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

declare -gx MIRROR_DIR="/mnt/mirror"
declare -gx REPOS_DIR="$MIRROR_DIR/git"
WORK_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
ALPINE_MIRROR="rsync://mirrors.dotsrc.org/alpine"
POSTMARKETOS_MIRROR="rsync://mirror.postmarketos.org/postmarketos"
ARCH_MIRROR="rsync://mirrors.dotsrc.org/archlinux"
ARCH_SOURCE_MIRROR="rsync://mirrors.kernel.org/archlinux/sources"
ARCH32_MIRROR="rsync://mirror.archlinux32.org/archlinux32"
ARTIX_MIRROR="rsync://universe.artixlinux.org/repos"
ARTIX_UNIVERSE_MIRROR="rsync://universe.artixlinux.org/universe"
ARCHARM_MIRROR="rsync://mirrors.dotsrc.org/archlinuxarm"
BLACKARCH_MIRROR="rsync://mirrors.dotsrc.org/blackarch"
ARCHCN_MIRROR="rsync://rsync.mirrors.ustc.edu.cn/repo/archlinuxcn"
VOID_MIRROR="rsync://mirrors.dotsrc.org/voidlinux"
ASTRA_MIRROR="rsync://download.astralinux.ru/astra/astra"
#ALT_MIRROR="rsync://rsync.altlinux.org/ALTLinux"
MXISO_MIRROR="rsync://mirrors.dotsrc.org/mx-isos"
#FEDORA_MIRROR="rsync://mirrors.dotsrc.org/fedora-buffet"
FEDORA_VIRTIO_MIRROR="rsync://fedorapeople.org/groups/virt/virtio-win"
CYGWIN_MIRROR="rsync://mirrors.dotsrc.org/cygwin"
OPENWRT_MIRROR="rsync://downloads.openwrt.org/downloads"
TINYCORE_MIRROR="rsync://tinycorelinux.net/tc"
APT_MIRROR="1" APT_MIRROR_FIX="0"
ORACLE_MIRROR="1"

function mirror_rsync() {
    if command -v rsync &> /dev/null; then
        if [[ "${*: -2:1}" == "/" ]]; then
            echo " [Not found mirror link for ${*: -1}! Skipping...]"
        else
            echo " [Mirroring from ${*: -2:1} to ${*: -1}...] {"
            [[ -d "${*: -1}" ]] || mkdir -p "${*: -1}"
            rsync --contimeout=3 --timeout=20 --recursive --links --copy-unsafe-links --times --sparse --delete --delete-after --delete-excluded --progress --stats --human-readable "$@" || echo "Failed to rsync ${*: -1}!"
            echo -e "}\n"
        fi
    fi
}

function git_update() {
    IFS=" " read -r -a repo_name <<< "$*"
    repo="${repo_name[0]}"
    name="${repo_name[1]}"
    echo " [Git update $name to $REPOS_DIR/$name...]"
    if [[ -d "$REPOS_DIR/$name/.git" ]]; then
        git -C "$REPOS_DIR/$name" pull origin master --rebase || echo "Failed to update $name!"
    else
        mkdir -p "$REPOS_DIR/$name"
        git clone "$repo" "$REPOS_DIR/$name" || echo "Failed to create $name!"
    fi
}

function git_update_list() {
    while IFS= read -r repo_name; do
        git_update "$repo_name"
    done < <(cat "$1")
}

cd "$MIRROR_DIR"

if command -v git &> /dev/null; then
    [[ -d "$REPOS_DIR" ]] || mkdir -p "$REPOS_DIR"
    git_update_list "$WORK_DIR/list.git/alpine"
    git_update_list "$WORK_DIR/list.git/dietpi"
    git_update_list "$WORK_DIR/list.git/openwrt"
    git_update_list "$WORK_DIR/list.git/postmarketos"
    git_update_list "$WORK_DIR/list.git/void"
fi

# --- ALPINELINUX MIRROR
mirror_rsync --exclude={"v3.[0-9]","v3.1[0-3]","edge/releases","*/*/armv7","*/*/mips64","*/*/ppc64le","*/*/riscv64","*/*/s390x"} $ALPINE_MIRROR/ alpine

# --- POSTMARKETOS MIRROR
mirror_rsync $POSTMARKETOS_MIRROR/ postmarketos

# --- ARCHLINUX MIRROR
for al_repo in core extra community multilib; do
    mirror_rsync $ARCH_MIRROR/$al_repo/ archlinux/$al_repo
done
for al_repo in core extra community; do
    mirror_rsync $ARCH32_MIRROR/i686/$al_repo/ archlinux32/i686/$al_repo
done
for al_repo in system world galaxy lib32; do
    mirror_rsync $ARTIX_MIRROR/$al_repo/ artix-linux/$al_repo/
done
mirror_rsync $ARTIX_UNIVERSE_MIRROR/ artix-linux/universe
mirror_rsync --exclude="arm*/" $ARCHARM_MIRROR/ archlinux-arm
mirror_rsync $BLACKARCH_MIRROR/blackarch/ blackarch
mirror_rsync --exclude="arm*/" $ARCHCN_MIRROR/ archlinuxcn
mirror_rsync $ARCH32_MIRROR/archisos/ archlinux32/archisos
mirror_rsync $ARCH_SOURCE_MIRROR/ arch_sources


# --- VOIDLINUX MIRROR
for al_repo in "docs" "live/current" "logos" "static" "void-updates"; do
    mirror_rsync $VOID_MIRROR/$al_repo/ voidlinux/$al_repo
done
mirror_rsync --exclude={"*.armv[6-7]l.xbps*","*.armv[6-7]l-musl.xbps*","aarch64/debug*","debug*"} $VOID_MIRROR/current/ voidlinux/current

# --- ASTRALINUX MIRROR
mirror_rsync --exclude={"frozen","stable/leningrad","stable/smolensk"} $ASTRA_MIRROR/ astralinux

# --- ALTLINUX MIRROR
mirror_rsync --exclude={"[2-5].[0-4]","Daedalus","autoimports/p[7-9]","backports","c[6-8]","c8.[0-1]","c9f1","cert6","old","p[5-9]","t[6-7]","ports","updates","autoimports"} \
    --exclude={"p10/images/*/*i586*","p10/images/*/*riscv64*","p10/images/*/*ppc64le*","p10/branch/i586","p10/branch/files/i586","p10/branch/ppc64le","p10/branch/files/ppc64le","p10/branch/armh","p10/branch/files/armh"} \
    --exclude={"Sisyphus/i586","Sisyphus/files/i586","Sisyphus/ppc64le","Sisyphus/files/ppc64le","Sisyphus/armh","Sisyphus/files/armh"} \
    $ALT_MIRROR/ altlinux

# --- MX-Linux ISO MIRROR
mirror_rsync $MXISO_MIRROR/ MX-Linux/MX-ISOs

# --- FEDORA MIRROR
mirror_rsync --exclude "4*" --exclude "5*" --exclude "6*" --exclude "7*" --exclude "8.*" --exclude "testing*" $FEDORA_MIRROR/ fedora/fedora-epel
mirror_rsync --exclude "deprecated-isos*" $FEDORA_VIRTIO_MIRROR/ fedora/groups/virt/virtio-win

# --- DEBIAN-BASED DISTROS MIRROR
if [[ "$APT_MIRROR" == "1" && -f "$WORK_DIR/apt-mirror-fixed" && -f "$MIRROR_DIR/apt/mirror.list" && -x $(command -v wget) && -x $(command -v gunzip) && -x $(command -v bzip2) && -x $(command -v xz) ]]; then
    "$WORK_DIR/apt-mirror-fixed" --config apt/mirror.list
    debian/var/clean.sh
    if [[ "$APT_MIRROR_FIX" == "1" ]]; then
        "$WORK_DIR/apt-mirror-fix" apt/mirror.list
        mirror_path=$(grep -F "set base_path" "$1" | tr -s " " | cut -d' ' -f3)
        bash "$mirror_path/mirror/download_X.sh"
        bash "$mirror_path/mirror/download_E.sh"
    fi
fi

# --- CYGWIN MIRROR
mirror_rsync $CYGWIN_MIRROR/ cygwin

# --- TINYCORE MIRROR
# Ignore "www" directory because it causes IO error.
mirror_rsync --exclude={"[1-9].x","1[0-1].x","www"} $TINYCORE_MIRROR tinycore

# --- OPENWRT MIRROR
mirror_rsync --bwlimit=4096 --exclude={"releases/1[7-9].*","releases/21.02.0","releases/21.02.0-rc[1-4]","releases/faillogs-1[7-9].*","releases/packages-1[7-9].*"} $OPENWRT_MIRROR openwrt

# --- ORACLELINUX 8 MIRROR
if [[ "$ORACLE_MIRROR" == "1" && -f /usr/bin/reposync && -f "$WORK_DIR/oracle_config.repo" ]]; then
  /usr/bin/reposync --bugfix --enhancement --newpackage --security --download-metadata --downloadcomps --remote-time --newest-only --delete --config "$WORK_DIR/oracle_config.repo" -p oraclelinux/
fi

# =)
echo "Script succesfully ended its work. Have a nice day!"
