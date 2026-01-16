# 教程: 将Shell脚本安装至终端PATH目录
> 将Shell脚本安装至终端PATH目录后只需要输入一个自定义的名称就可以快速启动对应的shell脚本而无需输入完整路径

## 操作步骤
### 1. 检查被安装的Shell脚本第一行是否为Shebang行，若没有需要自行添加到脚本的第一行
> 添加Shebang行的目的是告诉shell以什么解释器执行，以 `bash ...` 格式启动的脚本因为已经指定了解释器因此无需Shebang行，已经编译为二进制的文件也不需要Shebang行
- Android原生Shell(mksh): **#!/system/bin/sh**
- Android-Termux(bash): **#!/data/data/com.termux/files/usr/bin/bash**  
**注: Termux环境可通过修改Shebang行中的 `bash` 来自定义使用其他解释器，Android原生Shell需要系统支持其他解释器*

### 2. 复制需要安装的Shell脚本的完整路径
### 3. 复制终端的PATH路径
1. 执行 `echo "$PATH"` 命令查看输出
- 若输出格式为 **/...:/...:/...** 则任意选两个 **:** 符号的其中一个完整路径并复制
- 若输出格式为 **/.../.../...** 则直接完整复制
### 3. 执行以下命令完成操作
> 请将以下内容复制至一个文本编辑器或手机自带的笔记应用按要求修改后逐条执行

```shell
# 将此变量'...'之间的内容替换为shell脚本的完整路径
shell='/目录/文件夹/脚本'
# 将此变量'...'之间的内容替换为复制的PATH路径
path='/目录/文件夹'
# 将此变量'...'之间的内容替换为你想要的名称，此后只需要在终端执行该名称即可快速启动对应的shell脚本
name='cmd'
# ----------
cp "$shell" "$path/$name"
chmod +x "$path/$name"
# ----------
# 最后将下方的命令替换为自定义的命令执行测试
cmd
```

## 相关问题解答
### 问: 为什么在 `cp` 命令执行后报错**Permission denied**?
**答:** 若你正在尝试安装进Android系统自带的PATH路径那么需要使用Root权限才能完成，在未Root的情况下此教程仅适用于某些第三方终端如[Termux](https://termux.dev/cn/)