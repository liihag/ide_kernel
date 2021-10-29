- 参考https://github.com/amezin/vscode-linux-kernel
- 重点是 生成的 compile\_commands.json 以及修改c\_cpp_properties.json

compile_commands 语法：https://clang.llvm.org/docs/JSONCompilationDatabase.html

- 该项目是让拷贝这个.vscode到代码中

以下注意事项：

1.生成的compile_commands.json中directory有点类似这个节点的根目录，command和file只需要用相对这个目录的相对目录就行，output说不定也是

2.c\_cpp\_properties.json中的intelliSenseMode 可以配置成command中使用的clang？ 或者项目中介绍的c++？

# https://linlinhaohao888.github.io/2020/10/16/Importing-Linux-Kernel-Code-to-VS-Code-and-Enjoying-Code-Navigation/

[https://android.googlesource.com/kernel/common/+/688078e7/scripts/gen\_compile\_commands.py](https://android.googlesource.com/kernel/common/+/688078e7/scripts/gen_compile_commands.py)

* * *

* * *

# 20211029 有一次较大更新 notice:当前仍然有bug
## 需要注意以下bug： 
1 当前vscdode 用快速打开的文件，跳转函数时，会跳转到绝对目录的同一个文件，但是在另一个窗口打开。 不过不影响跳转。
2 调用generate.sh脚本后，需要通过modify_dir.sh将json文件中所有的目录改成vscode打开时候对应目录（可以在vscode终端中pwd），否则会无法跳转。





## 主要原理

进入到out目录下解析各个.cmd文件，然后组合成complie_commands.json文件.

## 原生的项目bug

原生项目生成的complie_commands.json能跳转，但是vscode跳转后文件的路径变得不是相对路径，从而会打开两个一样的文件。

## 解决方案

```diff
diff --git a/generate_compdb.py b/generate_compdb.py
index c433854..f80b9ca 100755
--- a/generate_compdb.py
+++ b/generate_compdb.py
@@ -27,13 +27,26 @@ def parse_cmd_file(out_dir, cmdfile_path):
         cmdfile_content = cmdfile.read()
 
     commands = { match.group(1): match.group(2) for match in CMD_VAR_RE.finditer(cmdfile_content) }
+#sources 是一个dict其内容类似如下：
+#{'drivers/gpu/drm/nouveau/dispnv50/head917d.o': '/work/android_x86/kernel/drivers/gpu/drm/nouveau/dispnv50/head917d.c'} 
     sources = { match.group(1): match.group(2) for match in SOURCE_VAR_RE.finditer(cmdfile_content) }
+    # print(sources)
+
+
+#source_arch/x86/crypto/chacha_glue.o := /work/android_x86/kernel/arch/x86/crypto/chacha_glue.c
+    for o_file_name, source in sources.items():
+        commands[o_file_name] = commands[o_file_name].replace("-MD,","-MD,"+out_dir+'/')
+        commands[o_file_name] = commands[o_file_name].replace("-I./","-I"+out_dir+'/')
+        commands[o_file_name] = commands[o_file_name].replace("-o ","-o "+out_dir+'/')      
+        if not source.startswith('/'):
+            sources[o_file_name]=out_dir+"/"+source
+
 
     return [{
-            'directory': out_dir,
+            'directory': ".",
             'command': commands[o_file_name],
             'file': source,
-            'output': o_file_name
+            'output': out_dir+'/'+o_file_name
         } for o_file_name, source in sources.items()]
```

这里需要参考complie_commands的[语法](https://clang.llvm.org/docs/JSONCompilationDatabase.html)，directory是一条command的初始目录，原生项目中被定为out目录，这是不对的。我将其定为 . ，即vscode打开时候kernel所在的目录。

但是这样改了后，需要解析commands中的各个目录。将其各个目录改成绝对路径。

最后，==通过sh脚本将需要修改的代码的绝对目录，修改成 ./形式的相对目录==。放到sh脚本处理的原因是因为有时候编译是在docker里面编译的，路径需要映射一下：

```
sed  -i 's/\/work\/android\_x86\/kernel\//\.\//g' compile_commands.json
```

### generate.sh脚本原理

对于AndroidX86项目，一般只需要到kenel目录下执行generate.sh脚本，该脚本会去上层目录下找out目录下的kernel目标文件。 从而进一步执行python脚本。

后面再处理下complie_commands.json的路径。