#!/bin/bash
###############################################################
### Mirror sync script
### Copyright (C) 2021 ALEXPRO100 (ktifhfl)
### License: GPL v3.0
###############################################################

set -e

declare -gx MIRROR_DIR="/mnt/mirror"
#declare -gx REPOS_DIR="$MIRROR_DIR/git"
WORK_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
#CPAN_MIRROR="rsync://cdimage.debian.org/mirror/CPAN"
#CTAN_MIRROR="rsync://cdimage.debian.org/mirror/CTAN"
ALPINE_MIRROR="rsync://mirrors.dotsrc.org/alpine"
POSTMARKETOS_MIRROR="rsync://mirror.postmarketos.org/postmarketos"
#POSTMARKETOS_IMAGES_MIRROR="rsync://mirror.postmarketos.org/images"
ARCH_MIRROR="rsync://mirrors.dotsrc.org/archlinux"
#ARCH_SOURCE_MIRROR="rsync://mirrors.kernel.org/archlinux/sources"
#MANJARO_MIRROR="rsync://mirror.truenetwork.ru/manjaro"
#ARCH32_MIRROR="rsync://mirror.archlinux32.org/archlinux32"
#ARTIX_MIRROR="rsync://universe.artixlinux.org/repos"
#ARTIX_UNIVERSE_MIRROR="rsync://universe.artixlinux.org/universe"
#ARCHARM_MIRROR="rsync://mirrors.dotsrc.org/archlinuxarm"
#BLACKARCH_MIRROR="rsync://mirrors.dotsrc.org/blackarch"
ARCHSTRIKE_MIRROR="rsync://cdimage.debian.org/mirror/archstrike.org"
MIRROR_CHAOTIC_AUR="rsync://builds.garudalinux.org/chaotic/chaotic-aur"
#ARCHCN_MIRROR="rsync://rsync.mirrors.ustc.edu.cn/repo/archlinuxcn"
#SOLYDXK_MIRROR="rsync://cdimage.debian.org/mirror/solydxk.com"
VOID_MIRROR="rsync://mirrors.dotsrc.org/voidlinux" # ~253GB
#ASTRA_MIRROR="rsync://dl.astralinux.ru/astra/astra"
ASTRA_MIRROR="rsync://mirror.yandex.ru/astra"
#ALT_MIRROR="rsync://rsync.altlinux.org/ALTLinux"
MXISO_MIRROR="rsync://mirrors.dotsrc.org/mx-isos"
#FDROID_MIRROR="rsync://mirrors.dotsrc.org/fdroid"
#FEDORA_MIRROR="rsync://mirrors.dotsrc.org/fedora-buffet"
FEDORA_VIRTIO_MIRROR="rsync://fedorapeople.org/groups/virt/virtio-win"
#APACHE_MIRROR="rsync://mirrors.dotsrc.org/apache"
#MYSQL_MIRROR="rsync://mirrors.dotsrc.org/mysql"
#CYGWIN_MIRROR="rsync://mirrors.dotsrc.org/cygwin"
#OPENWRT_MIRROR="rsync://openwrt.tetaneutral.net/openwrt"
#HAIKU_MIRROR="rsync://mirror.rit.edu/haiku"
#TINYCORE_MIRROR="rsync://tinycorelinux.net/tc" # ~72GB
APT_MIRROR="1" APT_MIRROR_FIX="0"
ORACLE_MIRROR="0"

function mirror_rsync() {
    if command -v rsync &> /dev/null; then
        if [[ ! "${*: -2:1}" =~ "rsync://" ]]; then
            echo " [Not found mirror link for ${*: -1}! Skipping...]"
        else
            echo " [Mirroring from ${*: -2:1} to ${*: -1}...] {"
            [[ "$RSYNC_FILE" == "1" || -d "${*: -1}" ]] || mkdir -p "${*: -1}"
            rsync --contimeout=20 --timeout=40 --recursive --links --copy-unsafe-links --times --sparse \
                --delete --delete-after --delete-excluded \
                --progress --stats --human-readable "$@" || echo "Failed to rsync ${*: -1}! Code exit is $?."
            echo -e "}\n"
        fi
    fi
}

function git_update() {
    local repo name exit_text=''
    IFS=" " read -r -a repo_name <<< "$*"
    repo="${repo_name[0]}"
    name="${repo_name[1]}"
    echo " [Git update $name to $REPOS_DIR/$name...]"
    if [[ -d "$REPOS_DIR/$name/.git" ]]; then
        git -C "$REPOS_DIR/$name" pull --all --prune --force -q --rebase || exit_text="update"
    else
        mkdir -p "$REPOS_DIR/$name"
        git clone "$repo" "$REPOS_DIR/$name" -q || exit_text="create"
    fi
    if [[ -n $exit_text ]]; then
        echo "--Failed to $exit_text $name!--"
        [[ $exit_text != "create" ]] || rm -rf "${REPOS_DIR:?}/$name"
    else
        echo -e "++Complete successfully.++"
    fi
}

cd "$MIRROR_DIR"

bash "$WORK_DIR/mikrotik.sh"

if [[ $(command -v git &> /dev/null) && -n "$REPOS_DIR" ]]; then
    [[ -d "$REPOS_DIR" ]] || mkdir -p "$REPOS_DIR"
    while IFS= read -r repo_list_file; do
        while IFS= read -r repo_name; do
            [[ -n "$repo_name" ]] || continue
            git_update "$repo_name"
        done < <(cat "$repo_list_file")
    done < <(find "$WORK_DIR/list.git" -type f)
fi

# --- CPAN and CTAN
mirror_rsync $CPAN_MIRROR/ CPAN
mirror_rsync $CTAN_MIRROR/ CTAN

# --- ALPINELINUX MIRROR
mirror_rsync --exclude={"v3.[0-9]","v3.1[0-5]","edge/releases","*/*/armv7","*/*/mips64","*/*/ppc64le","*/*/riscv64","*/*/s390x"} $ALPINE_MIRROR/ alpine

# --- POSTMARKETOS MIRROR
mirror_rsync $POSTMARKETOS_MIRROR/ postmarketos/postmarketos
mirror_rsync $POSTMARKETOS_IMAGES_MIRROR/ postmarketos/images

# --- ARCH-BASED MIRROR
mirror_rsync $ARCH_MIRROR/ archlinux
mirror_rsync $ARCH_SOURCE_MIRROR/ arch_sources
mirror_rsync --exclude="arm*/" $ARCHARM_MIRROR/ archlinux-arm
mirror_rsync $BLACKARCH_MIRROR/ blackarch
mirror_rsync $MIRROR_CHAOTIC_AUR/ chaotic-aur
mirror_rsync --exclude="arm*/" $ARCHCN_MIRROR/ archlinuxcn
mirror_rsync $ARCH32_MIRROR/ archlinux32
mirror_rsync $ARTIX_MIRROR/ artix-linux/repos
mirror_rsync $ARTIX_UNIVERSE_MIRROR/ artix-linux/universe
mirror_rsync $MANJARO_MIRROR/ manjaro
mirror_rsync $ARCHSTRIKE_MIRROR/ archstrike

# --- SOLYDXK.COM
mirror_rsync $SOLYDXK_MIRROR/ solydxk

# --- VOIDLINUX MIRROR
mirror_rsync --exclude={"live/201*","live/2020*","live/20210[2-3]*","void-updates","distfiles","current/*.armv[6-7]l.xbps*","current/*.armv[6-7]l-musl.xbps*","current/aarch64/debug*","current/debug*","current/musl/debug*"} $VOID_MIRROR/ voidlinux

# --- ASTRALINUX MIRROR
RSYNC_FILE=1 mirror_rsync $ASTRA_MIRROR/README-ASTRA.txt astra/README-ASTRA.txt
mirror_rsync --exclude={"leningrad","smolensk"} $ASTRA_MIRROR/stable/ astra/stable

# --- ALTLINUX MIRROR
mirror_rsync --exclude={"[2-5].[0-4]","Daedalus","autoimports/p[7-9]","backports","c[6-8]","c8.[0-1]","c9f1","cert6","old","p[5-9]","t[6-7]","ports","updates","autoimports"} \
    --exclude={"p10/images/*/*i586*","p10/images/*/*riscv64*","p10/images/*/*ppc64le*","p10/branch/i586","p10/branch/files/i586","p10/branch/ppc64le","p10/branch/files/ppc64le","p10/branch/armh","p10/branch/files/armh"} \
    --exclude={"Sisyphus/i586","Sisyphus/files/i586","Sisyphus/ppc64le","Sisyphus/files/ppc64le","Sisyphus/armh","Sisyphus/files/armh"} \
    $ALT_MIRROR/ altlinux

# --- MX-Linux ISO MIRROR
mirror_rsync $MXISO_MIRROR/ MX-Linux/MX-ISOs

# --- F-Droid MIRROR
mirror_rsync --exclude="archive" $FDROID_MIRROR/ fdroid

# --- FEDORA MIRROR
mirror_rsync --exclude={"alt","archive","epel/7*","epel/8/*/s390x","epel/8/*/ppc64le","epel/9/*/s390x","epel/9/*/ppc64le","epel/next/8/*/s390x","epel/next/8/*/ppc64le","epel/next/9/*/s390x",,"epel/next/9/*/ppc64le","epel/playground","epel/testing","fedora/linux/releases/3[4-5]","fedora/linux/releases/test","fedora/linux/updates/3[4-5]","fedora/linux/updates/testing","fedora/linux/development","fedora-secondary"} $FEDORA_MIRROR/ fedora/fedora-buffet
mirror_rsync --exclude "deprecated-isos*" $FEDORA_VIRTIO_MIRROR/ fedora/groups/virt/virtio-win

# --- APACHE SOFTWARE MIRROR
mirror_rsync $APACHE_MIRROR/ apache

# --- MYSQL SOFTWARE MIRROR (Only connectors)
# --exclude={"Downloads/MySQL-[4-7]*","Downloads/MySQL-Cluster-[4-7]*"} - For latest mysql software
mirror_rsync --exclude={"Downloads/MySQL-[4-8]*","Downloads/MySQL-Cluster-[4-8]*"} $MYSQL_MIRROR/ mysql

# --- DEBIAN-BASED DISTROS MIRROR
if [[ "$APT_MIRROR" == "1" && -x $(command -v wget) && -x $(command -v gunzip) && -x $(command -v bzip2) && -x $(command -v xz) ]]; then
    "$WORK_DIR/apt-mirror-fixed" --config apt/mirror.list || NO_APT_ACTIONS=1
    [[ $NO_APT_ACTIONS == "1" ]] || debian/var/clean.sh
    if [[ $NO_APT_ACTIONS != "1" && "$APT_MIRROR_FIX" == "1" ]]; then
        "$WORK_DIR/apt-mirror-fix" apt/mirror.list
        mirror_path=$(grep -F "set base_path" "$1" | tr -s " " | cut -d' ' -f3)
        bash "$mirror_path/mirror/download_X.sh"
        bash "$mirror_path/mirror/download_E.sh"
    fi
    unset NO_APT_ACTIONS
fi

# --- CYGWIN MIRROR
mirror_rsync $CYGWIN_MIRROR/ cygwin

# --- TINYCORE MIRROR
# Ignore "www" directory because it causes IO error.
mirror_rsync --exclude={"[1-9].x","1[0-1].x","www"} $TINYCORE_MIRROR/ tinycore

# --- OPENWRT MIRROR
mirror_rsync --exclude={"releases/1[7-9].*","releases/21.02.0-rc[1-4]","releases/faillogs-1[7-9].*","releases/packages-1[7-9].*","snapshots"} $OPENWRT_MIRROR openwrt

# --- HAIKU MIRROR
mirror_rsync $HAIKU_MIRROR/ haiku

# --- ORACLELINUX 8 MIRROR
if [[ "$ORACLE_MIRROR" == "1" && -f /usr/bin/reposync && -f "$WORK_DIR/oracle_config.repo" ]]; then
  /usr/bin/reposync --bugfix --enhancement --newpackage --security --download-metadata \
    --downloadcomps --remote-time --newest-only --delete --config "$WORK_DIR/oracle_config.repo" -p oraclelinux/
fi

# =)
echo "Script succesfully ended its work. Have a nice day!"
