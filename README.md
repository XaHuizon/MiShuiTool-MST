# MiShuiTool - Termux刷机工具
![平台](https://img.shields.io/badge/%E9%80%82%E7%94%A8%E5%B9%B3%E5%8F%B0-Android--64%20%7C%20Termux-yellow)
![版本](https://img.shields.io/badge/%E5%BD%93%E5%89%8D%E7%89%88%E6%9C%AC-2026.1.13--Beta-brightgreen)
![协议](https://img.shields.io/badge/%E5%BC%80%E6%BA%90%E5%8D%8F%E8%AE%AE-Apache--2.0-blue)
### 作者信息:
- 作者: **MiShui&Mi丶XaFlash**
- 开发日期: **2025年3月28日**
- Email: [@Mi丶XaFlash](mailto:311461xhl@gmail.com)
- Gitee: [@Xa丶Hui](https://gitee.com/XaHui-GitHub/mi-shui-tool)
 - GitHub:[@Mi_XaFlash](https://github.com/XaHuizon/MiShuiTool-MST)
- 开源协议: [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
> 本项目采用 Apache-2.0 协议开源，你可以自由地使用、修改和分发本代码，但必须保留原始的版权声明，同时，本项目不提供任何形式的担保，刷机风险由使用者自行承担
## 简介
![HOME_PNG](https://raw.githubusercontent.com/XaHuizon/MiShuiTool-MST/main/PNG/MST-HOME.jpg)
- **MiShuiTool**是一个用于在**无PC环境**受限场景中的临时解决方案，使用它仅需要**一部手机**(*注: 指主机设备*)与一根**OTG转接线**以及**最新版本**的[Termux](https://f-droid.org/repo/com.termux_1022.apk)与[Termux-Api](https://f-droid.org/repo/com.termux.api_1000.apk)就可以完成大部分简单的调试操
> 本工具旨在为**无PC环境**但需要使用ADB&Fastboot功能的用户提供一个方便的**Termux**刷机环境，其中针对**ADB**及**Fastboot**的部分常用操作均提供了高度自动化的快捷功能，脚本内置大量的检测逻辑，但是百密终有一疏，执行高危操作前务必备份好数据，，对于不了解的操作一定要了解清楚后再继续
### Fastbooot功能简介:
- 支持刷入镜像如Boot/Recovery以及自定义分区
- 支持刷入zip/tgz格式的Rom
- 支持重启处于Fastboot模式的设备
### ADB功能简介:
- 支持激活Shizuku、Scene等ADB应用，
- 支持对应用进行冻结/解冻、安装/卸载应用、提取应用Apk等简单应用管理
- 支持修改/恢复连接设备分辨率、设置目标设备墓碑模式等简单系统设设置
- 支持重启处于ADB模式的设备
> 另外MiShuiTool还可以连接任何处于ADB/Fastboot模式的设备（需允许USB调试）
## 安装与使用
### 在终端中执行以下命令以一键安装/更新:
```shell
curl -sS https://raw.githubusercontent.com/XaHuizon/MiShuiTool-MST/main/install | bash 
```

- **安装完成后执行 `mishuitool` 命令即可启动MST工具箱**
# 鸣谢
> 本项目引用了以下开源项目的安装命令，如果您认为他们还不错，请为他们点上一颗Star！

## MiUnlockTool
### 开发者信息
- **GitHub地址:** [MiUnlockTool](https://github.com/offici5l/MiUnlockTool)
- **开源协议:** [Apache-2.0](https://github.com/offici5l/MiUnlockTool/blob/main/LICENSE)
- **开发者:** [@offici5l](https://github.com/offici5l)

- **用途:** __解锁小米设备相关__
### 引用的命令: 
```shell
curl -sS https://raw.githubusercontent.com/offici5l/MiUnlockTool/main/.install | bash
```

## termux-adb
### 开发者信息
- **GitHub地址:** [termux-adb](https://github.com/nohajc/termux-adb)
- **开源协议:** [MIT](https://github.com/nohajc/termux-adb/blob/master/LICENSE)
- **开发者:** [@nohajc](https://github.com/nohajc)

- **用途:** __无Root权限使用adb命令__
### 引用的命令: 
```shell
curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash
```
