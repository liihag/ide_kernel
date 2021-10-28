#!/bin/bash
sed_src="/media/ecarx/yly/android_x86"
sed_tar="/home/ecarx/work/nvme/android_x86"

sed -i "s|$sed_src|$sed_tar|g" /home/ecarx/work/nvme/android_x86/kernel/compile_commands.json
