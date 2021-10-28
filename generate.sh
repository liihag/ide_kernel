#!/bin/bash
echo -e "****\n注意: \n执行完该脚本后，必须通过ide打开realpath的绝对路径才行，否则会有链接错误问题。\n   如果你需要解决这个问题，用脚本后面注释的sed指令即可\n****"






echo "开始生成"
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
CURRENT_DIR=`pwd`
echo $DIR
echo $CURRENT_DIR

if [ -f "compile_commands.json" ] ; then
    echo "删除老的json文件"
    rm compile_commands.json
fi

target_out=$1

if [ -z $target_out ]; then
    echo "no out parm"
    target_product=`ls ../out/target/product/`
    echo "target_product:${target_product}"
    if [ -d ../out/target/product/${target_product}/obj/KERNEL_OBJ ]; then
        target_out=../out/target/product/${target_product}/obj/KERNEL_OBJ/
        echo "找到默认的target out：${target_out}"
#for android X86        
    elif [ -d ../out/target/product/${target_product}/obj/kernel/ ]; then
        target_out=../out/target/product/${target_product}/obj/kernel/
        echo "找到默认的target out：${target_out}"        
    else
        target_out=`find ../out -name KERNEL_OBJ`
        echo "使用find 找到 out的kernelobj"
    fi
    echo "target out：${target_out}"

    
fi

#realpath 指的是不包含软链接绝对地址
realpath=`python -c "import os; print(os.path.realpath('${CURRENT_DIR}/${target_out}'))"`

#realpath 指的是包含软链接绝对地址
abspath=`python -c "import os; print(os.path.abspath('${CURRENT_DIR}/${target_out}'))"`

echo $realpath
echo $abspath



python $DIR/generate_compdb.py  -O $target_out

#############用下面的三条指令来更换你的路径
# sed_src="/media/ecarx/yly/android_x86"
# sed_tar="/home/ecarx/work/nvme/android_x86"
# sed -i "s|$sed_src|$sed_tar|g" compile_commands.json


#$DIR/kernel-grok/generate_cmake -d $CURRENT_DIR
#echo -e "SET(CMAKE_C_COMPILER "gcc")\ninclude_directories(".")\ninclude_directories("./include")" >> CMakeLists.txt


