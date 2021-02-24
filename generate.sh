#!/bin/bash
echo "开始生成"
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
CURRENT_DIR=`pwd`
echo $DIR
echo $CURRENT_DIR
rm compile_commands.json
python $DIR/vscode-linux-kernel/generate_compdb.py  -O $1
#fix the path of compile_commands.json
sed  -i 's/\/work\//\/home\/ecarx\/work\//g' compile_commands.json
sed  -i 's/\/home\/ecarx\/home\/ecarx\//\/home\/ecarx\//g' compile_commands.json
#$DIR/kernel-grok/generate_cmake -d $CURRENT_DIR
#echo -e "SET(CMAKE_C_COMPILER "gcc")\ninclude_directories(".")\ninclude_directories("./include")" >> CMakeLists.txt


