#!/bin/bash
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
    else
        target_out=`find ../out -name KERNEL_OBJ`
        echo "使用find 找到 out的kernelobj"
    fi
    echo "target out：${target_out}"

    
fi

python $DIR/vscode-linux-kernel/generate_compdb.py  -O $target_out
#fix the path of compile_commands.json
sed  -i 's/\/work\//\/home\/ecarx\/work\//g' compile_commands.json
sed  -i 's/\/home\/ecarx\/home\/ecarx/\/home\/ecarx/g' compile_commands.json
sed  -i 's/\/media\/ecarx\/yly/\/home\/ecarx\/work\/nvme/g' compile_commands.json
sed  -i 's/\/media\/ecarx\/yly/\/home\/ecarx\/work\/nvme/g' compile_commands.json

#$DIR/kernel-grok/generate_cmake -d $CURRENT_DIR
#echo -e "SET(CMAKE_C_COMPILER "gcc")\ninclude_directories(".")\ninclude_directories("./include")" >> CMakeLists.txt


