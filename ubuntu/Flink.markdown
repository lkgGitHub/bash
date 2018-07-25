# Flink on Windows
如果你想要在本地的一台 Windows 上运行 Flink，你需要下载和解压Flink压缩包。之后，你可以使用使用 Windows Batch 文件（.bat文件即windows批处理文件）或者使用 Cygwin 运行 Flink 的 JobMnager。
# 使用 Windows 批处理文件启动
通过 Windows 批处理文件在本地模式下启动Flink，首先打开命令行窗口，进入 Flink 的 bin/ 目录，然后运行 start-local.bat 。

注意：Java运行环境必须已经加到了 Windows 的PATH环境变量中。按照本指南添加 Java 到PATH环境变量中。
```
$ cd flink
$ cd bin
$ start-local.bat
开始Flink job manager. 默认web界面地址为 http://localhost:8081/
不要关闭这个cmd窗口.。通过Ctri+C 来停止job manager。
```
之后，你需要打开新的命令行窗口，并运行flink.bat。
# 使用 Cygwin 和 Unix 脚本启动
使用 Cygwin 你需要打开 Cygwin 的命令行，进入 Flink 目录，然后运行start-local.sh脚本：
```
$ cd flink
$ bin/start-local.sh
Starting jobmanager
```
# 从 Git 安装 Flink

如果你是正在从git仓库安装 Flink，同时正在使用的 Windows git shell，Cygwin会产生一个类似于下面的错误：

`c:/flink/bin/start-local.sh: line 30: $'\r': command not found`

这个错误的产生是因为 git 运行在 Windows 上时，会自动地将 UNIX 换行转换成 Windows 换行。问题是，Cygwin 只认 Unix 换行。解决方案是调整 Cygwin 配置来正确处理换行。步骤如下：

1. 打开 Cygwin 命令行
2. 确定 home 目录，通过输入

   `cd;pwd`

   它会返回 Cygwin 根目录下的一个路径。

3. 在home目录下，使用 NotePad, WordPad 或者其他编辑器打开.bash_profile文件，然后添加如下内容到文件末尾：（如果文件不存在，你需要创建它）
```
export SHELLOPTS
set -o igncr
```
保存文件，然后打开一个新的bash窗口。
