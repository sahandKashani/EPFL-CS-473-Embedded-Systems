#!/bin/bash -x

# make sure to be in the same directory as this script
script_dir_abs=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "${script_dir_abs}"

# constants ####################################################################
sdcard_fat32_dir="$(readlink -m "sdcard/fat32")"
sdcard_fat32_rbf_file="$(readlink -m "${sdcard_fat32_dir}/socfpga.rbf")"
sdcard_fat32_uboot_img_file="$(readlink -m "${sdcard_fat32_dir}/u-boot.img")"
sdcard_fat32_uboot_scr_file="$(readlink -m "${sdcard_fat32_dir}/u-boot.scr")"
sdcard_fat32_zImage_file="$(readlink -m "${sdcard_fat32_dir}/zImage")"
sdcard_fat32_dtb_file="$(readlink -m "${sdcard_fat32_dir}/socfpga.dtb")"

sdcard_dev="$(readlink -m "${1}")"

sdcard_ext3_rootfs_tgz_file="$(readlink -m "sdcard/ext3_rootfs.tar.gz")"

sdcard_a2_dir="$(readlink -m "sdcard/a2")"
sdcard_a2_preloader_bin_file="$(readlink -m "${sdcard_a2_dir}/preloader-mkpimage.bin")"

sdcard_partition_size_fat32="32M"
sdcard_partition_size_linux="512M"

sdcard_partition_number_fat32="1"
sdcard_partition_number_ext3="2"
sdcard_partition_number_a2="3"

if [ "$(echo "${sdcard_dev}" | grep -P "/dev/sd\w.*$")" ]; then
    sdcard_dev_fat32_id="${sdcard_partition_number_fat32}"
    sdcard_dev_ext3_id="${sdcard_partition_number_ext3}"
    sdcard_dev_a2_id="${sdcard_partition_number_a2}"
elif [ "$(echo "${sdcard_dev}" | grep -P "/dev/mmcblk\w.*$")" ]; then
    sdcard_dev_fat32_id="p${sdcard_partition_number_fat32}"
    sdcard_dev_ext3_id="p${sdcard_partition_number_ext3}"
    sdcard_dev_a2_id="p${sdcard_partition_number_a2}"
fi

sdcard_dev_fat32="${sdcard_dev}${sdcard_dev_fat32_id}"
sdcard_dev_ext3="${sdcard_dev}${sdcard_dev_ext3_id}"
sdcard_dev_a2="${sdcard_dev}${sdcard_dev_a2_id}"
sdcard_dev_fat32_mount_point="$(readlink -m "sdcard/mount_point_fat32")"
sdcard_dev_ext3_mount_point="$(readlink -m "sdcard/mount_point_ext3")"

# usage() ######################################################################
usage() {
    cat <<EOF
===================================================================================
usage: write_sdcard.sh [sdcard_device]

positional arguments:
    sdcard_device    path to sdcard device file    [ex: "/dev/sdb", "/dev/mmcblk0"]
===================================================================================
EOF
}

# echoerr() ####################################################################
echoerr() {
    cat <<< "${@}" 1>&2;
}

# partition_sdcard() ###########################################################
partition_sdcard() {
    # manually partitioning the sdcard
        # sudo fdisk /dev/sdx
            # use the following commands
            # n p 3 <default> 4095  t   a2 (2048 is default first sector)
            # n p 1 <default> +32M  t 1  b (4096 is default first sector)
            # n p 2 <default> +512M t 2 83 (69632 is default first sector)
            # w
        # result
            # Device     Boot Start     End Sectors  Size Id Type
            # /dev/sdb1        4096   69631   65536   32M  b W95 FAT32
            # /dev/sdb2       69632 1118207 1048576  512M 83 Linux
            # /dev/sdb3        2048    4095    2048    1M a2 unknown
        # note that you can choose any size for the FAT32 and Linux partitions,
        # but the a2 partition must be 1M.

    # automatically partitioning the sdcard
    # wipe partition table
    sudo dd if="/dev/zero" of="${sdcard_dev}" bs=512 count=1

    # create partitions
    # no need to specify the partition number for the first invocation of
    # the "t" command in fdisk, because there is only 1 partition at this
    # point
    echo -e "n\np\n3\n\n4095\nt\na2\nn\np\n1\n\n+${sdcard_partition_size_fat32}\nt\n1\nb\nn\np\n2\n\n+${sdcard_partition_size_linux}\nt\n2\n83\nw\nq\n" | sudo fdisk "${sdcard_dev}"

    # create filesystems
    sudo mkfs.vfat "${sdcard_dev_fat32}"
    sudo mkfs.ext3 -F "${sdcard_dev_ext3}"
}

# write_sdcard() ###############################################################
write_sdcard() {
    # create mount point for sdcard
    mkdir -p "${sdcard_dev_fat32_mount_point}"
    mkdir -p "${sdcard_dev_ext3_mount_point}"

    # mount sdcard partitions
    sudo mount "${sdcard_dev_fat32}" "${sdcard_dev_fat32_mount_point}"
    sudo mount "${sdcard_dev_ext3}" "${sdcard_dev_ext3_mount_point}"

    # preloader
    sudo dd if="${sdcard_a2_preloader_bin_file}" of="${sdcard_dev_a2}" bs=64K seek=0

    # fpga .rbf, uboot .img, uboot .scr, linux zImage, linux .dtb
    sudo cp "${sdcard_fat32_dir}"/* "${sdcard_dev_fat32_mount_point}"

    # linux rootfs
    pushd "${sdcard_dev_ext3_mount_point}"
    sudo tar -xzf "${sdcard_ext3_rootfs_tgz_file}"
    popd

    # flush write buffers to target
    sudo sync

    # unmount sdcard partitions
    sudo umount "${sdcard_dev_fat32_mount_point}"
    sudo umount "${sdcard_dev_ext3_mount_point}"

    # delete mount points for sdcard
    rm -rf "${sdcard_dev_fat32_mount_point}"
    rm -rf "${sdcard_dev_ext3_mount_point}"
}

# Script execution #############################################################
if [ ! -d "${sdcard_a2_dir}" ]; then
    mkdir -p "${sdcard_a2_dir}"
fi

if [ ! -d "${sdcard_fat32_dir}" ]; then
    mkdir -p "${sdcard_fat32_dir}"
fi

if [ ! -b "${sdcard_dev}" ]; then
    usage
    echoerr "Error: could not find block device at \"${sdcard_dev}\""
    exit 1
fi

partition_sdcard
write_sdcard

# Make sure MSEL = 000000
