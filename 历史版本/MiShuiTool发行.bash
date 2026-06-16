#!/data/data/com.termux/files/usr/bin/bash
COLOR_30="\033[0;30;1m";COLOR_31="\033[0;31;1m"
COLOR_32="\033[0;32;1m";COLOR_33="\033[0;33;1m"
COLOR_34="\033[0;34;1m";COLOR_35="\033[0;35;1m"
COLOR_36="\033[0;36;1m";COLOR_37="\033[0;37;1m"
COLOR_0="\033[0m";COLOR_01="\033[0;1m"
if [ "$(id -u)" = "0" ]
then
    COLOR="$COLOR_31"
else
    COLOR="$COLOR_36"
fi
SHOW_FUNC_MENU() {
    FUNC_CONT=0
    while true
    do
        CLEAR_LINE
        echo -e "$ALL_TIP_TION"
        for ALL_INPUT in "${!ALL_OPTION[@]}"
        do
            if [ "$ALL_INPUT" -eq "$FUNC_CONT" ]
            then
                echo -e "${COLOR_33}|>${ALL_OPTION[$ALL_INPUT]}${COLOR_0}"
            else
                echo -e "${COLOR_36}| ${ALL_OPTION[$ALL_INPUT]}${COLOR_0}"
            fi
        done
        echo -e -n "${COLOR_35} [Tip]${COLOR_33}上下/数字键选择 空格/回车键确定${COLOR_0}\r"
        read -s -n1 ALL_CON
        if [ "$ALL_CON" = "A" ]
        then
            FUNC_CONT=$((FUNC_CONT - 1))
            if [ $FUNC_CONT -lt 0 ]
            then
                FUNC_CONT=$((${#ALL_OPTION[@]} - 1))
            fi
        elif [ "$ALL_CON" = "B" ]
        then
            FUNC_CONT=$((FUNC_CONT + 1))
            if [ $FUNC_CONT -ge ${#ALL_OPTION[@]} ]
            then
                FUNC_CONT=0
            fi
        elif [[ "$ALL_CON" =~ ^[1-$OPTION_NUB]+$ ]]
        then
            ALL_CON=$((ALL_CON - 1))
            FUNC_CONT="$ALL_CON"
        elif [ -z "$ALL_CON" ]
        then
            break
        fi
    done
    FUNC_CONT=$((FUNC_CONT + 1))
    echo
    echo -e "${COLOR_37}------------------------------------—${COLOR_0}"
}
ERROR_CONT() {
    echo -e "${COLOR_31}[!]${COLOR_33}异常选项:${COLOR_36}$FUNC_CONT${COLOR_0}"
    REBOOT_FL
}
ALL_REBOOT() {
    sleep 0.4
    CA_FLASH_MAIN
    return
}
REBOOT_FL() {
    echo
    echo -e -n "${COLOR}[MST]${COLOR_33}点按回车返回主页${COLOR_0}"
    read -s
    echo
    echo -e -n "${COLOR_34}[BACK]${COLOR_33}返回主页...${COLOR_0}"
    ALL_REBOOT
}
SU_REBOOR_FL() {
    echo
    echo -e -n "${COLOR}[MST]${COLOR_33}返回主页...${COLOR_0}"
    ALL_REBOOT
}
MAIN_REBOOT() {
    echo -e -n "${COLOR}[MST]${COLOR_33}返回主页...${COLOR_0}"
    ALL_REBOOT
}
EXIT_SHELL() {
    local EXIT_CODE="${EXIT_CODE:-0}"
    echo -e "${COLOR_35}[EXIT]${COLOR_33}退出脚本(退出码:${COLOR_36}$EXIT_CODE${COLOR_33})...${COLOR_0}"
    exit "$EXIT_CODE"
}
BACK_TO_SHELL() {
    echo -e "${COLOR_35}[BACK]${COLOR_33}已从命令提示符返回脚本${COLOR_0}"
    echo -e -n "${COLOR_36}[1›返回主页/2›退出脚本]*ᐷ${COLOR_01}"
    read EXIT_YN
    case "$EXIT_YN" in     
    1)
        CA_FLASH_MAIN
        ;;
    *)
        EXIT_SHELL
        ;;
    esac
}
NOW_LINE() {
    IFS=';' read -sdR -p $'\E[6n' NOW_LINE COL
    NOW_LINE="${NOW_LINE#*[}"
}
CLEAR_LINE() {
    echo -e -n "\033[$NOW_LINE;1H"
    echo -e -n "\033[J"
}
USB_DEVICES_FASTBOOT() {
    FASTBOOT_DEVICES_BOOTLOADER() {
        FB_DEV_BL=$(fastboot getvar unlocked 2>&1 | grep 'lock' | sed 's/.*: //g')
        FB_DEV_TOKEN=$(fastboot getvar token 2>&1 | grep 'token' | sed 's/.*: //g')
        FB_DEV_SLOT=$(fastboot getvar current-slot 2>&1 | grep 'slot :' | sed 's/.*slot: //g')
        if [ -z "$FB_DEV_TOKEN" ]
        then
            FB_DEV_TOKEN="${COLOR_31}未知${COLOR_0}"
        fi
        case "$FB_DEV_SLOT" in
        'a')
            FB_DEV_SLOT="${COLOR_32}A${COLOR_0}"
            ;;
        'b')
            FB_DEV_SLOT="${COLOR_32}B${COLOR_0}"
            ;;
        *)
            if [ -z "$FB_DEV_SLOT" ]
            then
                FB_DEV_SLOT="${COLOR_31}不支持${COLOR_0}"
            else
                FB_DEV_SLOT="${COLOR_31}未知${COLOR_0}"
            fi
            ;;
        esac
        case "$FB_DEV_BL" in
        'yes')
            FB_DEV_BL="${COLOR_32}已解锁${COLOR_0}"
            ;;
        'no')
            FB_DEV_BL="${COLOR_31}未解锁${COLOR_0}"
            ;;
        *)
            FB_DEV_BL="${COLOR_31}未知${COLOR_0}"
            ;;
        esac
        echo -e "${COLOR_35}[FASTBOOT]${COLOR_33}设备信息 >>${COLOR_0}"
        echo -e "${COLOR_33}设备指纹:${COLOR_32}$FB_DEV_TOKEN${COLOR_0}"
        echo -e "${COLOR_33}BL锁状态:${COLOR_32}$FB_DEV_BL${COLOR_0}"
        echo -e "${COLOR_33}设备当前A/B槽位:$FB_DEV_SLOT${COLOR_0}"
    }
    echo -e -n "${COLOR_35}[FASTBOOT]${COLOR_33}设备连接状态:${COLOR_0}"
    FASTBOOT_DEVICES="$(fastboot devices 2>&1)"
    FASTBOOT_GETVAR="$(timeout 3 fastboot getvar serialno 2>&1 | sed 's/<.*//g')"
    if [ -z "$FASTBOOT_DEVICES" ] && [ -z "$FASTBOOT_GETVAR" ]
    then
        echo -e "${COLOR_31}未连接设备${COLOR_0}"
        return 1
    elif [ -z "$FASTBOOT_DEVICES" ] && [ -n "$FASTBOOT_GETVAR" ]
    then
        FASTBOOT_GETVAR=$(echo "$FASTBOOT_GETVAR" | grep 'serialno:' | sed 's/serialno://g')
        echo -e "${COLOR_36}$FASTBOOT_GETVAR fastboot${COLOR_32}-已连接${COLOR_0}"
        FASTBOOT_DEVICES_BOOTLOADER
        return 0
    else
        FASTBOOT_DEVICES=$(echo "$FASTBOOT_DEVICES" | grep 'fast' | sed 's/ .*//g')
        echo -e "${COLOR_36}$FASTBOOT_DEVICES fastboot${COLOR_32}-已连接${COLOR_0}"
        FASTBOOT_DEVICES_BOOTLOADER
        return 0
    fi
}
USB_DEVICES_ADB() {
    echo -e -n "${COLOR_35}[ADB]${COLOR_33}设备连接状态:${COLOR_0}"
    adb kill-server &>>/dev/null && adb start-server &>>/dev/null
    sleep 1
    ADB_DEVICES=$(adb get-serialno 2>/dev/null | grep -E '[0-9].*[a-zA-Z]|[a-zA-Z].*[0-9]')
    if [ -z "$ADB_DEVICES" ]
    then
        echo -e "${COLOR_31}未连接设备${COLOR_0}"
        return 1
    else
        echo -e "${COLOR_36}$ADB_DEVICES adb${COLOR_32}-已连接${COLOR_0}"
        CPU_GHZ=$(adb shell "MAX_GHZ=\$(cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | sort -n | tail -1); echo \"scale=2; \$MAX_GHZ / 1000000\" | bc" 2>/dev/null)
        CPUNAME=$(adb shell grep 'Hardware' /proc/cpuinfo 2>/dev/null | sed 's/.*: //g; s/, /-/g' 2>/dev/null)
        OSV=$(adb shell getprop ro.build.version.release 2>/dev/null)
        CPUUN=$(adb shell grep -c "processor" /proc/cpuinfo 2>/dev/null)
        DEVONE=$(adb shell getprop ro.product.device 2>/dev/null)
        DEVTWO=$(adb shell getprop ro.product.model 2>/dev/null)
        UINAME=$(adb shell getprop ro.build.display.id 2>/dev/null)
        KERNEL=$(adb shell uname -r 2>/dev/null)
        WIFI=$(adb shell getprop gsm.version.baseband 2>/dev/null)
        DEV_SDK=$(adb shell getprop ro.build.version.sdk 2>/dev/null)
        DEV_NAME=$(adb shell getprop ro.product.brand 2>/dev/null)
        ALL_ABC=("CPUNAME" "OSV" "CPUUN" "DEVONE" "DEVTWO" "UINAME" "KERNEL" "WIFI" "DEV_SDK" "DEV_NAME" "CPU_GHZ")
        for ABC in "${ALL_ABC[@]}"
        do
            if [ -z "${!ABC}" ]
            then
                declare "$ABC=${COLOR_31}未知${COLOR_0}"
            fi
        done
        echo -e "${COLOR_35}[ADB]${COLOR_33}已连接设备信息 >>${COLOR_0}"
        echo -e "${COLOR_33}设备:${COLOR_32}$DEV_NAME $DEVTWO ($DEVONE)${COLOR_0}"
        echo -e "${COLOR_33}CPU:${COLOR_32}$CPUNAME ${COLOR_32}($CPUUN核)${COLOR_33}/最大频率:${COLOR_32}$CPU_GHZ GHz${COLOR_0}"
        echo -e "${COLOR_33}内核:${COLOR_32}$KERNEL${COLOR_0}"
        echo -e "${COLOR_33}基带:${COLOR_32}$WIFI${COLOR_0}"
        echo -e "${COLOR_33}系统:${COLOR_32}$UINAME${COLOR_33}/Android${COLOR_32} $OSV (SDK:$DEV_SDK)${COLOR_0}"
        return 0
    fi
}
ADB_FASTBOOT_VER() {
    echo -e "${COLOR_35}[ADB]${COLOR_33}当前版本 >>${COLOR_32}"
    adb --version | grep 'version'
    echo -e "${COLOR_35}[Fastboot]${COLOR_33}当前版本 >>${COLOR_32}"
    fastboot --version | grep 'version'
    echo -e -n "${COLOR_0}\r"
}
REBOOT_USB_DEVICES() {
    ALL_OPTION=("1*-重启至FASTBOOT-线刷模式" "2*-重启至RECOVERY-卡刷/恢复模式" "3*-重启至系统" "4*-返回主页")
    OPTION_NUB=4
    NOW_LINE
    SHOW_FUNC_MENU
    case "$FUNC_CONT" in
    '1')
        REBOOT_PT='fastboot'
        REBOOT_NAME='FASTBOOT'
        REBOOT_TAP='+音量-'
        ;;
    '2')
        REBOOT_PT='recovery'
        REBOOT_NAME='RECOVERY'
        REBOOT_TAP='+音量+'
        ;;
    '3')
        REBOOT_PT=''
        REBOOT_NAME='系统'
        ;;
    '4')
        MAIN_REBOOT
        ;;
    *)
        ERROR_CONT
        ;;
    esac
    echo -e "${COLOR_35}[Rebooting]${COLOR_33}正在将目标设备重启至'${COLOR_36}$REBOOT_NAME${COLOR_33}'模式...${COLOR_30}"
    if $ADB_FASTBOOT_CMD reboot $REBOOT_PT
    then
        echo -e "${COLOR_32}[OKAY]${COLOR_33}已将目标设备重启至'${COLOR_36}$REBOOT_NAME${COLOR_33}'模式${COLOR_0}"
        REBOOT_FL
    else
        echo -e "${COLOR_31}[ERROR]${COLOR_33}重启目标设备失败${COLOR_0}"
        echo -e "${COLOR_35}[Tip]${COLOR_33}可长按'${COLOR_36}关机键$REBOOT_TAP键${COLOR_33}'手动重启${COLOR_0}"
        REBOOT_FL
    fi
}
INSTALL_THE_NUST_CMD() {
    if ! command -v $NOT_INSTALL_CMD &>/dev/null
    then
        echo -e "${COLOR_31}[ERROR]${COLOR_33}没有在当前环境(${COLOR_36}$PATH${COLOR_33})中找到'${COLOR_36}$NOT_INSTALL_CMD${COLOR_33}'命令${COLOT_0}"
        echo
        case "$PREFIX" in
        '/data/data/com.termux/files/usr')
            echo -e "${COLOR_35}[GET]${COLOR_33}是否安装'${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}'工具包 >>${COLOR_0}"
            echo -e -n "${COLOR_36}[+][1›立即安装/2›取消并退出]*ᐷ${COLOR_01}"
            read YN_INSTALL_CMD
            case "$YN_INSTALL_CMD" in
            '1' | 'y' | 'Y')
                echo -e "${COLOR_35}[Installing]${COLOR_33}正在安装...${COLOR_0}"
                if NOW_LINE && eval "$INSTALL_ITS_CMD" && CLEAR_LINE
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}工具包'${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}'安装成功${COLOR_0}"
                    ADB_FASTBOOT_VER
                    REBOOT_FL
                else
                    EXIT_CODE="$?"
                    echo -e "${COLOR_31}[ERROR]${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}安装失败 尝试连接魔法或手动执行命令 >>${COLOR_0}"
                    echo -e "${COLOR_33} - 命令1: ${COLOR_36}pkg update -y && pkg upgrade -y${COLOR_0}"
                    echo -e "${COLOR_33} - 命令2: ${COLOR_36}$INSTALL_ITS_CMD${COLOR_0}"
                    EXIT_SHELL
                fi
                ;;
            *)
                EXIT_SHELL
                ;;
            esac
            ;;
        *)
            echo -e "${COLOR_31}[!]${COLOR_33}当前环境(${COLOR_36}$PATH${COLOR_33})非Termux无法运行${COLOR_0}"
            echo -e "${COLOR_35}[Tip]${COLOR_33}在Termux中使用'${COLOR_36} bash $0 ${COLOR_33}'命令执行脚本${COLOR_0}"
            EXIT_SHELL
            ;;
        esac
    fi
}
SEE_USB_DEVICES() {
    MISHUI_MAIN
    if ! USB_DEVICES_$ADB_FASTBOOT_NAME
    then
        echo -e "${COLOR_31}[!]${COLOR_33}没有设备连接无法继续${COLOR_0}"
        echo -e "${COLOR_35}[Tip]${COLOR_33}在主页中使用'${COLOR_36}连接设备${COLOR_33}'功能连接设备后再试${COLOR_0}"
        REBOOT_FL
    fi
    echo
}
CA_FLASH_MAIN() {
    MISHUI_MAIN() {
        clear
        echo -e "${COLOR}[MiShuiTool]${COLOR_33}Termux刷机工具箱${COLOR_36}/MST CLI${COLOR_33} 版本${COLOR_32}V1.0.0-Beta${COLOR_0}"
        echo -e "${COLOR}  __    __ _ ____  _           _ _____           _ ${COLOR_0}"
        echo -e "${COLOR} |  \  /  (_) ___|| |__  _   _(_)_   _|__   ___ | |${COLOR_0}"
        echo -e "${COLOR} | |\\\\\\//| | (___ \|  _ \| | | | | | |/ _ \ / _ \| |${COLOR_0}"
        echo -e "${COLOR} | | \/ | | |___) | | | | |_| | | | | (_) | (_) | |${COLOR_0}"
        echo -e "${COLOR} |_|    |_|_|____/|_| |_|\__,_|_| |_|\___/ \___/|_|${COLOR_0}"
        echo -e "${COLOR_30}---------------------------------------------------${COLOR_0}"
        echo -e "$COLOR[MST]${COLOR_33}当前时间:[${COLOR_32}$(date +%Y.%m.%d)${COLOR_33}/${COLOR_32}$(date +%H:%M:%S)${COLOR_33}] $MISHUI_MAIN_TIP >>${COLOR_0}"
    }
    MISHUI_MAIN_TIP=MiShuiTool
    MISHUI_MAIN
    INSTALL_ITS_CMD="curl -sS 'https://raw.githubusercontent.com/offici5l/termux-adb-fastboot/refs/heads/main/install' | bash"
    NOT_INSTALL_TOOLS='ADB&Fastboot'
    NOT_INSTALL_CMD='fastboot'
    INSTALL_THE_NUST_CMD
    INSTALL_ITS_CMD="pkg install termux-api -y"
    NOT_INSTALL_TOOLS='Termux-API'
    NOT_INSTALL_CMD='termux-usb'
    INSTALL_THE_NUST_CMD
    echo -e "${COLOR_35}[DEV]${COLOR_33}›1*-${COLOR_36}管理连接设备${COLOR_35}[FB]${COLOR_33}›2*-${COLOR_36}Fastboot刷机工具${COLOR_0}"
    echo -e "${COLOR_35}[ADB]${COLOR_33}›3*-${COLOR_36}ADB调试工具 ${COLOR_35}[UBL]${COLOR_33}›4*-${COLOR_36}解锁BL锁(第三方工具)${COLOR_0}"
    echo -e "${COLOR_35}[INST]${COLOR_33}›5*-${COLOR_36}安装第三方Termux-Fastboot&ADB命令${COLOR_0}"
    echo -e "${COLOR_35}[RE]${COLOR_33}›6*-${COLOR_36}重启MST工具箱${COLOR_35}[EXIT]${COLOR_33}›7*-${COLOR_36}退出MST工具箱${COLOR_0}"
    echo -e -n "${COLOR}[-${COLOR_32}CA${COLOR}-]${COLOR_33}输入选项*ᐷ${COLOR_0}"
    read INPUT_USR
    echo -e "${COLOR_30}-------------------------------------------------${COLOR_0}"
    case "$INPUT_USR" in
    '1' | 'DEV' | '管理连接设备')
        CNT_ANY_DEVICED() {
            MISHUI_MAIN
            echo
            if USB_DEVICES_$FASTBOOT_OR_ADB_NAME
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}$FASTBOOT_OR_ADB_NAME设备已就绪无需重复连接${COLOR_0}"
                REBOOT_FL
            else
                echo -e "${COLOR_35}[>>]${COLOR_33}自动连接设备中...${COLOR_0}"
                if DEVICES_PATH=$(termux-usb -l 2>&1 | grep '/' | sed 's/ //g; s/"//g') && [ -n "$DEVICES_PATH" ]
                then
                    echo -e "${COLOR_35}[USB]${COLOR_33}发现可连接设备:${COLOR_36}$DEVICES_PATH${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_33}已向该设备发送连接请求 10秒内弹窗点击确认${COLOR_0}"
                    timeout 10 termux-usb -r -e $SHELL -E "$DEVICES_PATH"
                    echo -e "${COLOR_35}[FB]${COLOR_33}验证设备连接...${COLOR_0}"
                    if USB_DEVICES_$FASTBOOT_OR_ADB_NAME
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}设备连接成功${COLOR_0}"
                        REBOOT_FL
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}设备连接失败 重试一次或使用ROOT模式执行${COLOR_0}"
                        REBOOT_FL
                    fi
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}没有发现可连接设备${COLOR_0}"
                    echo -e "${COLOR_36}[建议]${COLOR_33}重新插入USB设备/重启Termux/检查数据线是否正确连接/重启目标设备以尝试解决问题${COLOR_0}"
                    REBOOT_FL
                fi
            fi
            REBOOT_FL
        }
        MISHUI_MAIN_TIP=管理连接设备
        MISHUI_MAIN
        echo
        ALL_TIP_TION="${COLOR}[DEV]${COLOR_33}选择设备管理功能 >>${COLOR_0}"
        ALL_OPTION=("1*-连接ADB设备" "2*-连接FASTBOOT设备" "3*-返回主页")
        OPTION_NUB=3
        NOW_LINE
        SHOW_FUNC_MENU
        case "$FUNC_CONT" in
        '1')
            MISHUI_MAIN_TIP=连接ADB设备
            FASTBOOT_OR_ADB_NAME='ADB'
            CNT_ANY_DEVICED
            ;;
        '2')
            MISHUI_MAIN_TIP=连接FASTBOOT设备
            FASTBOOT_OR_ADB_NAME='FASTBOOT'
            CNT_ANY_DEVICED
            ;;
        '3')
            MAIN_REBOOT
            ;;
        *)
            ERROR_CONT
            ;;
        esac
        ;;
    '2' | 'FB' | 'Fastboot刷机工具')
        NOT_UNLOCK_ERROR() {
            if [ -z "$1" ]
            then
                local TIP_TEXT=镜像没刷对
            else
                local TIP_TEXT="$1"
            fi
            case "$FB_DEV_BL" in
            'no')
                echo -e "${COLOR_35}[WARN]${COLOR_31}当前Fastboot设备BootLoader未解锁${COLOR_0}"
                echo -e "${COLOR_31}[!]${COLOR_33}要继续操作必须先为Fastboot设备${COLOR_36}解锁BootLoader${COLOR_33}(BL锁)${COLOR_0}"
                ;;
            *)
                echo -e "${COLOR_35}[WARN]${COLOR_31}刷入不兼容的镜像文件可能导致设备无法开机${COLOR_0}"
                echo -e "${COLOR_32} - 刷机千万条 谨慎第一条 -${COLOR_0}"
                echo -e "${COLOR_32} - $TIP_TEXT 机主两行泪 -${COLOR_0}"
                echo
                ;;
           esac
        }
        ADB_FASTBOOT_NAME=FASTBOOT
        ADB_FASTBOOT_CMD=fastboot
        MISHUI_MAIN_TIP=Fastboot刷机工具
        MISHUI_MAIN
        echo
        echo -e "${COLOR}[FB]${COLOR_33}选择Fastboot功能 >>${COLOR_0}"
        echo -e "${COLOR_35}[BOOT]${COLOR_33}›1*-${COLOR_36}刷入BOOT${COLOR_35}[REC]${COLOR_33}›2*-${COLOR_36}刷入RECOVERY${COLOR_35}[RE]${COLOR_33}›3*-${COLOR_36}重启连接设备${COLOR_0}"
        echo -e "${COLOR_35}[SLOT]${COLOR_33}›4*-${COLOR_36}刷入指定分区${COLOR_35}[ROM]${COLOR_33}›5*-${COLOR_36}刷入ROM${COLOR_35}[HOME]${COLOR_33}›6*-${COLOR_36}返回主页${COLOR_0}"
        echo -e -n "${COLOR}[-${COLOR_32}FB${COLOR}-]${COLOR_33}输入选项*ᐷ${COLOR_0}"
        read FUNC_CONT
        echo -e "${COLOR_30}-------------------------------------------------${COLOR_0}"
        FLASH_IMG_TO_SLOT() {
            echo -e "${COLOR_35}[FILE]${COLOR_33}输入要刷入'${COLOR_36}$FLASH_IMG_NAME${COLOR_33}'分区的镜像文件路径 >>${COLOR_0}"
            echo -e -n "${COLOR_33}*ᐷ${COLOR_01}"
            read IMG_FILE_PATH
            IMG_FILE_NAME=$(basename "$IMG_FILE_PATH" 2>/dev/null)
            if [ -z "$IMG_FILE_PATH" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}输入不可为空${COLOR_0}"
                REBOOT_FL
            elif [ ! -f "$IMG_FILE_PATH" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}文件'${COLOR_36}$IMG_FILE_NAME${COLOR_33}'路径不存在/无法读取${COLOR_0}"
                REBOOT_FL
            fi
            echo -e "$COLOR_35[Flashing]${COLOR_33}正在将'${COLOR_36}$IMG_FILE_NAME${COLOR_33}'刷入'${COLOR_36}$FLASH_IMG_NAME${COLOR_33}'分区...${COLOR_0}"
            if fastboot flash $FLASH_IMG_SLOT $IMG_FILE_PATH
            then
                ALL_TIP_TION="${COLOR_32}[OKAY]${COLOR_33}刷入成功 是否立即重启 >>${COLOR_0}"
                REBOOT_USB_DEVICES
            else
                echo -e "${COLOR_32}[ERROR]${COLOR_33}刷入失败 检查设备是否正确连接或镜像文件是否正确${COLOR_0}"
                REBOOT_FL
            fi
        }
        case "$FUNC_CONT" in
        '1' | 'BOOT' | '刷入BOOT')
            MISHUI_MAIN_TIP=刷入BOOT
            SEE_USB_DEVICES
            NOT_UNLOCK_ERROR
            echo -e "${COLOR_35}[SLOT]${COLOR_33}选择要刷入的分区 >>$COLOR_0"
            echo -e "${COLOR_36}›1*-Boot ›2*-Boot_a  ›3*-Boot_b ›4*-init_boot${COLOR_0}"
            echo -e "›5*-init_Boot_a ›6*-init_boot_b ›7*-自动识别${COLOR_01}"
            echo -e -n "${COLOR_35}[ST]${COLOR_33}输入选项*ᐷ${COLOR_01}"
            read YN_SLOT_AB
            case "$YN_SLOT_AB" in
            '1' | 'Boot')
                FLASH_IMG_NAME=BOOT
                FLASH_IMG_SLOT=boot
                ;;
            '2' | 'a' | 'A' | 'Boot_a')
                FLASH_IMG_NAME=BOOT_A
                FLASH_IMG_SLOT=boot_a
                ;;
            '3' | 'b' | 'B' | 'Boot_b')
                FLASH_IMG_NAME=BOOT_B
                FLASH_IMG_SLOT=boot_b
                ;;
            '4' | 'init' | 'init_Boot')
                FLASH_IMG_NAME=INIT_BOOT
                FLASH_IMG_SLOT=init_boot
                ;;
            '5' | 'init_a' | 'init_boot_a')
                FLASH_IMG_NAME=INIT_BOOT_A
                FLASH_IMG_SLOT=init_boot_a
                ;;
            '6' | 'init_b' | 'init_boot_b')
                FLASH_IMG_NAME=INIT_BOOT_B
                FLASH_IMG_SLOT=init_boot_b
                ;;
            '7' | '自动' | '自动识别')
                AUTO_TO_SEE_SLOT="$(fastboot getvar all 2>&1)"
                if grep 'type:init_boot' <<< "$AUTO_TO_SEE_SLOT"
                then
                    FLASH_IMG_NAME=INIT_BOOT
                    FLASH_IMG_SLOT=init_boot
                elif grep 'type:boot' <<< "$AUTO_TO_SEE_SLOT"
                then
                    FLASH_IMG_NAME=BOOT
                    FLASH_IMG_SLOT=boot
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}自动识别Boot分区失败 需手动指定Boot分区${COLOR_0}"
                    REBOOT_FL
                fi
                ;;
            *)
                if [ -z "$YN_SLOT_AB" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                    REBOOT_FL
                fi
                echo -e "${COLOR_31}[!]${COLOR_33}不支持的选项:${COLOR_36}$YN_SLOT_AB${COLOR_0}"
                REBOOT_FL
                ;;
            esac
            FLASH_IMG_TO_SLOT
            ;;
        '2' | 'REC' | '刷入RECOVERY')
            MISHUI_MAIN_TIP=刷入RECOVERY
            SEE_USB_DEVICES
            NOT_UNLOCK_ERROR
            FLASH_IMG_NAME=RECOVERY
            FLASH_IMG_SLOT=recovery
            FLASH_IMG_TO_SLOT
            ;;
        '3' | 'RE' | '重启连接设备')
            MISHUI_MAIN_TIP=重启连接设备
            SEE_USB_DEVICES
            ALL_TIP_TION="${COLOR_32}[RE]${COLOR_33}选择需要重启的目标模式 >>${COLOR_0}"
            REBOOT_USB_DEVICES
            ;;
        '4' | 'SLOT' | '刷入指定分区')
            MISHUI_MAIN_TIP=刷入指定分区
            SEE_USB_DEVICES
            NOT_UNLOCK_ERROR
            echo -e "${COLOR_35}[SLOT]${COLOR_33}输入要刷入的分区名称*ᐷ${COLOR_01}"
            read FLASH_IMG_SLOT
            if [ -z "$FLASH_IMG_SLOT" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}输入不可为空${COLOR_0}"
                REBOOT_FL
            else
                echo -e "${COLOR_35}[Y/N]${COLOR_33}是否确定指定分区为:${COLOR_36}$FLASH_IMG_SLOT${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›确定分区/2›返回主页]*ᐷ${COLOR_01}"
                read YN_INPUT_SLOT
                case "$YN_INPUT_SLOT" in
                '1' | 'y' | 'Y')
                    FLASH_IMG_NAME=$FLASH_IMG_SLOT
                    echo -e "${COLOR_32}[CFM]${COLOR_33}已确定指定分区为:${COLOR_36}$YN_INPUT_SLOT${COLOR_0}"
                    ;;
                *)
                    MAIN_REBOOT
                    ;;
                esac
            fi
            FLASH_IMG_TO_SLOT
            ;;
        '5' | '刷入ROM' | 'ROM')
            MISHUI_MAIN_TIP=刷入ROM
            SEE_USB_DEVICES
            NOT_UNLOCK_ERROR "刷机包不对"
            echo -e "${COLOR_35}[PATH]${COLOR_33}输入${COLOR_36}'线刷包${COLOR_33}'或${COLOR_36}'解压后文件夹${COLOR_33}'的完整路径 >>${COLOR_0}"
            echo -e -n "${COLOR_33}*ᐷ${COLOR_01}"
            read ZIP_DIR_PATH
            if [ -f "$ZIP_DIR_PATH" ]
            then
                echo -e "${COLOR_35}[ZIP]${COLOR_33}该路径指向为:${COLOR_36}线刷包${COLOR_0}"
                THE_FILE_EXT_NAME="${ZIP_DIR_PATH##*.}"
                THE_FILE_FLASH_NAME="$(basename "$ZIP_DIR_PATH")"
                THE_PATH_FLASH_NAME="$(dirname "$ZIP_DIR_PATH")/线刷包-MST"
                if ! mkdir -p "$THE_PATH_FLASH_NAME"
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}无法创建用户存放解压后文件的文件夹 脚本无法自动解压该压缩包(${COLOR_36}$THE_FILE_FLASH_NAME$COLOR_33) 手动解压后输入${COLOR_36}解压后文件夹${COLOR_0}路径以继续${COLOR_0}"
                    REBOOT_FL
                fi
                case "$THE_FILE_EXT_NAME" in
                'zip')
                    NOT_INSTALL_TOOLS='unzip'
                    NOT_INSTALL_CMD='unzip'
                    INSTALL_ITS_CMD="pkg install unzip -y"
                    INSTALL_THE_NUST_CMD
                    UNZIP_CMD() {
                        if unzip "$ZIP_DIR_PATH" -d "$THE_PATH_FLASH_NAME" && TMP_UNZIP_DIR=$(find "$THE_PATH_FLASH_NAME" -mindepth 1 -maxdepth 1 -type d -print -quit) && mv "$TMP_UNZIP_DIR"/* "$THE_PATH_FLASH_NAME/" 2>/dev/null
                        then
                            return 0
                        else
                            return 1
                        fi
                    }
                    ;;
                    'tgz' | 'tar' | 'gz' | 'bz2' | 'xz' | 'zst' | 'lzma' | 'Z')
                    NOT_INSTALL_TOOLS='tar'
                    NOT_INSTALL_CMD='tar'
                    INSTALL_ITS_CMD="pkg install tar -y"
                    INSTALL_THE_NUST_CMD
                    UNZIP_CMD() {
                        if tar -xvzf "$ZIP_DIR_PATH" --strip-components=1 -C "$THE_PATH_FLASH_NAME"
                        then
                            return 0
                        else
                            return 1
                        fi
                    }
                    ;;
                *)
                    echo -e "${COLOR_31}[?]${COLOR_33}未知的文件后缀:${COLOR_36}$THE_FILE_EXT_NAME${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_33}目前仅支持对'${COLOR_36}.zip${COLOR_33}'与'${COLOR_36}.tgz${COLOR_33}'压缩文件直接操作 其他格式需手动解压${COLOR_0}"
                    REBOOT_FL
                    ;;
                esac
                echo -e "${COLOR_35}[UZ]${COLOR_33}正在解压'${COLOR_36}$THE_FILE_FLASH_NAME${COLOR_33}'文件...${COLOR_30}"
                if UNZIP_CMD
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}已将线刷包解压至文件夹:${COLOR_36}$THE_PATH_FLASH_NAME${COLOR_0}"
                else
                     echo -e "${COLOR_31}[ERROR]${COLOR_33}线刷包解压失败 尝试手动解压并输入${COLOR_36}文件夹${COLOR_33}路径${COLOR_0}"
                    REBOOT_FL
                fi
            elif [ -d "$ZIP_DIR_PATH" ]
            then
                echo -e "${COLOR_35}[DIR]${COLOR_33}该路径指向为:${COLOR_36}文件夹${COLOR_30}"
                THE_PATH_FLASH_NAME="${ZIP_DIR_PATH%/}"
            else
                echo -e "${COLOR_31}[!]${COLOR_33}路径不存在或无法访问${COLOR_0}"
                REBOOT_FL
            fi
            SH_FILE_NUM=1
            echo -e "${COLOR_35}[FIND]${COLOR_33}正在查找刷机包文件夹中的'${COLOR_36}.sh${COLOR_33}'刷机脚本...${COLOR_0}"
            for ONE_SH_FILE in "$THE_PATH_FLASH_NAME"/*.sh
            do
                if [ -n "$ONE_SH_FILE" ]
                then
                    ALL_SH_FILE+=$ONE_SH_FILE$'\n'
                    echo -e "${COLOR_33}›$SH_FILE_NUM*-${COLOR_36}$(basename "$ONE_SH_FILE")${COLOR_0}"
                    SH_FILE_NUM=$((SH_FILE_NUM + 1))
                fi
                continue
            done
            if [ -z "$ALL_SH_FILE" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}没有找到'${COLOR_36}.sh${COLOR_33}'刷机脚本${COLOR_0}"
                echo -e "${COLOR_35}[Tip]${COLOR_33}检查该文件夹是否指向刷机包解压后的文件夹${COLOR_0}"
                REBOOT_FL
            fi
            echo -e -n "${COLOR_35}[SH]${COLOR_33}输入需要使用的脚本选项*ᐷ${COLOR_01}"
            read USR_SH_NUMBER
            case "$USR_SH_NUMBER" in
            *[1-9]*)
                USR_SH_FALSH="$(sed ${USR_SH_NUMBER}p <<< "$ALL_SH_FILE")"
                if [ -z "$USR_SH_FAL" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$USR_SH_NUMBER${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL
                else
                    echo -e "${COLOR_35}[USR]${COLOR_33}是否使用'${COLOR_36}$(basename "$USR_SH_FALSH")${COLOR_33}'脚本进行刷机 >>${COLOR_0}"
                    echo -e "${COLOR_36}[+][1›确认使用/2›取消并返回主页]*ᐷ${COLOR_01}"
                    read YN_CONTINUE_FLASH
                    case "$YN_CONTINUE_FLASH" in
                    '2' | 'n' | 'N')
                        MAIN_REBOOT
                        ;;
                    esac
                fi
                ;;
            *)
                if [ -z "$USR_SH_NUMBER" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                    sleep 0.3
                    MAIN_REBOOT
                fi
                echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$USR_SH_NUMBERL_YN${COLOR_33}'非菜单中的选项${COLOR_0}"
                REBOOT_FL
                ;;
            esac
            echo
            echo -e -n "${COLOR_35}[+/-]${COLOR_33}当前电量:${COLOR_0}"
            NOW_PEAGE=$(termux-battery-status | grep 'percentage' | sed 's/.*: //g; s/,//g')
            ALL_PEAGE=$(termux-battery-status | grep 'scale' | sed 's/.*: //g; s/,//g')
            NUMBER_PEAGR="${COLOR_36}$NOW_PEAGE%${COLOR_33}/${COLOR_36}$ALL_PEAGE%${COLOR_33}-"
            if [ "$NOW_PEAGE" -ge '80' ]
            then
                echo -e "$NUMBER_PEAGR${COLOR_32}电量充足${COLOR_0}"
            elif [ "$NOW_PEAGE" -lt '40' ]
            then
                echo -e "$NUMBER_PEAGR${COLOR_31}严重不足${COLOR_0}"
                echo -e "${COLOR_35}[WARN]${COLOR_31}本机当前电量严重不足 必须保证本机电量高于${COLOR_36}40%${COLOR_31}才能顺利完成刷入${COLOR_0}"
                REBOOT_FL
            else
                echo -e "$NUMBER_PEAGR${COLOR_34}电量较足${COLOR_0}"
                echo -e "${COLOR_35}[INFO]${COLOR_33}本机当前电量较为充足但仍然存在断电风险 是否继续 >>${COLOR_0}"
                echo -e "${COLOR_36}[+][1›继续刷入/2›取消并返回主页]*ᐷ${COLOR_01}"
                read PEABG_CONTINUE_YN
                case "$PEABG_CONTINUE_YN" in
                '1' | 'y' | 'Y')
                    echo -e "${COLOR_35}[CONTINUE]${COLOR_33}已确认继续操作${COLOR_0}"
                    ;;
                *)
                    MAIN_REBOOT
                    ;;
                esac
            fi
            echo
            echo -e "${COLOR_35}[WARN]${COLOR_31}刷入之前必须确保所选刷机包与目标设备相符 刷入中将设备(${COLOR_36}本机与目标设备${COLOR_31})与数据线平放并避免触碰以保证刷入过程中不会意外中断${COLOR_0}"
            echo -e -n "${COLOR_35}[TIME]${COLOR_33}1秒后开始刷入${COLOR_0}\r"
            sleep 1
            echo
            echo -e "${COLOR_35}[Flashing]${COLOR_33}正在使用'${COLOR_36}$(basename "$USR_SH_FALSH")${COLOR_33}'刷机脚本刷入ROM...${COLOR_0}"
            if FLASH_START=$(date +%s.%N) && bash "$USR_SH_FALSH" && FLASH_END=$(date +%s.%N)
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}刷入完毕 设备可能已被刷机脚本自动重启${COLOR_0}"
                OKAY_PEAGE=$(termux-battery-status | grep 'percentage' | sed 's/.*: //g; s/,//g')
                echo -e "${COLOR_35}[COMP]${COLOR_33}消耗电量:${COLOR_36}$(awk "BEGIN {printf \"%.2f\", $NOW_PEAGE - $OKAY_PEAGE}")%${COLOR_33}/耗时:${COLOR_36}$(awk "BEGIN {printf \"%.2f\", $FLASH_END - $FLASH_START}")s${COLOR_0}"
                REBOOT_FL
            else
                echo -e "${COLOR_31}[ERROR]${COLOR_33}刷入失败 检查刷机包是否与设备相符或刷入过程中数据线是否意外断开${COLOR_0}"
                REBOOT_FL
            fi
            ;;
        '6' | 'HOME' | '返回主页')
            MAIN_REBOOT
            ;;
        *)
            ERROR_CONT
            ;;
        esac
        ;;
    '3' | 'ADB' | 'ADB调试工具')
        ADB_FASTBOOT_NAME=ADB
        ADB_FASTBOOT_CMD=adb
        MISHUI_MAIN_TIP=ADB调试工具
        MISHUI_MAIN
        echo
        echo -e "${COLOR}[ADB]${COLOR_33}选择ADB调试项目 >>${COLOR_0}"
        echo -e "${COLOR_35}[ACT]${COLOR_33}›1*-${COLOR_36}激活ADB应用${COLOR_35}[APP]${COLOR_33}›2*-${COLOR_36}应用管理${COLOR_35}[CMD]${COLOR_33}›3*-${COLOR_36}自定义ADBShell命令${COLOR_0}"
        echo -e "${COLOR_35}[SET]${COLOR_33}›4*-${COLOR_36}高级系统设置${COLOR_35}[RE]${COLOR_33}›5*-${COLOR_36}重启连接设备${COLOR_35}[HOME]${COLOR_33}›6*-${COLOR_36}返回主页${COLOR_0}"
        echo -e -n "${COLOR}[-${COLOR_32}ADB${COLOR}-]${COLOR_33}输入选项*ᐷ${COLOR_0}"
        read FUNC_CONT
        echo -e "${COLOR_30}-------------------------------------------------${COLOR_0}"
        case "$FUNC_CONT" in
        '1' | 'ACT' | '激活ADB应用')
            MISHUI_MAIN_TIP=激活ADB应用
            SEE_USB_DEVICES
            ACT_ADB_APP() {
                echo -e "${COLOR_35}[P-ACT]${COLOR_33}正在激活'${COLOR_36}$ACT_APP_NAME${COLOR_33}'...${COLOR_0}"
                if adb shell am start -n $START_APP_CMD && adb shell sh $ACT_APP_PATH
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}激活'${COLOR_36}$ACT_APP_NAME${COLOR_33}'命令执行完毕${COLOR_0}"
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}激活'${COLOR_36}$ACT_APP_NAME${COLOR_33}'命令执行失败${COLOR_0}"
                    echo -e "${COLOR_35}[CMD]${COLOR_33}手动激活命令: ${COLOR_36}adb shell sh $ACT_APP_PATH${COLOR_0}"
                fi
            }
            ALL_TIP_TION="${COLOR_35}[APP]${COLOR_33}已支持ADB激活的应用 >>${COLOR_0}"
            ALL_OPTION=("1*-Shizuku-ADB" "3*-Scene6-ADB" "3*-黑阈-ADB" "4*-全部激活-3个" "5*-返回主页")
            OPTION_NUB=5
            NOW_LINE
            SHOW_FUNC_MENU
            case "$FUNC_CONT" in
            '1')
                ACT_APP_NAME='Shizuku-ADB'
                ACT_APP_PATH='/storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
                START_APP_CMD='moe.shizuku.privileged.api/moe.shizuku.manager.MainActivity'
                ;;
            '2')
                ACT_APP_NAME='Scene6-ADB'
                ACT_APP_PATH='/storage/emulated/0/Android/data/com.omarea.vtools/up.sh'
                START_APP_CMD='com.omarea.vtools/com.omarea.vtools.activities.ActivityStartSplash'
                ;;
            '3')
                ACT_APP_NAME='黑阈-ADB'
                ACT_APP_PATH='/data/data/me.piebridge.brevent/brevent.sh'
                START_APP_CMD='me.piebridge.brevent/me.piebridge.brevent.ui.BreventActivity'
                ;;
            '4')
                ACT_APP_NAME='Shizuku-ADB'
                ACT_APP_PATH='/storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
                START_APP_CMD='moe.shizuku.privileged.api/moe.shizuku.manager.MainActivity'
                ACT_ADB_APP
                ACT_APP_NAME='Scene6-ADB'
                ACT_APP_PATH='/storage/emulated/0/Android/data/com.omarea.vtools/up.sh'
                START_APP_CMD='com.omarea.vtools/com.omarea.vtools.activities.ActivityStartSplash'
                ACT_ADB_APP
                ACT_APP_NAME='黑阈-ADB'
                ACT_APP_PATH='/data/data/me.piebridge.brevent/brevent.sh'
                START_APP_CMD='me.piebridge.brevent/me.piebridge.brevent.ui.BreventActivity'
                ACT_ADB_APP
                REBOOT_FL
                ;;
            '5')
                MAIN_REBOOT
                ;;
            *)
                ERROR_CONT
            ;;
            esac
            ACT_ADB_APP
            REBOOT_FL
            ;;
        '2' | 'APP' | '应用管理')
            MISHUI_MAIN_TIP=应用管理
            MISHUI_MAIN
            echo
            SEARCH_THE_NEED_APPS() {
                echo -e "${COLOR_35}[PKGE]${COLOR_33}输入包名或包名关键词以搜索应用(多包名使用'${COLOR_36}-${COLOR_33}'符号区分) >>${COLOR_0}"
                echo -e -n "${COLOR_33}*ᐷ${COLOR_01}"
                read INPUT_PKGE_NAME
                if [ -z "$INPUT_PKGE_NAME" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                    REBOOT_FL
                else
                    IFS='-' read -ra INPUT_PKGE_NAME <<< "$INPUT_PKGE_NAME"
                fi
                echo
                echo -e "${COLOR_35}[SRCH]${COLOR_33}正在搜索包含'${COLOR_36}${INPUT_PKGE_NAME[*]}${COLOR_33}'的包名...${COLOR_0}"
                ALL_LIIST_PKGE="$(adb shell pm list packages --user current)"
                if [ -z "$ALL_LIIST_PKGE" ]
                then
                    ALL_LIIST_PKGE="$(adb shell pm list packages)"
                fi
                PKGE_NUMBER=1
                ALL_SEARCH=""
                for ONE_SEARCH in "${INPUT_PKGE_NAME[@]}"
                do
                    OKAY_SEARCH=$(echo "$ALL_LIIST_PKGE" | sed 's/.*age://g' | grep -- "$ONE_SEARCH")
                    while IFS= read -r SEARCH_LINR
                    do
                        if [ -n "$SEARCH_LINR" ]
                        then
                            echo -e "${COLOR_33}›$PKGE_NUMBER*-${COLOR_36}$SEARCH_LINR${COLOR_0}"
                            PKGE_NUMBER=$((PKGE_NUMBER + 1))
                        fi
                    done <<< "$OKAY_SEARCH"
                    if [ -n "$OKAY_SEARCH" ]
                    then
                        ALL_SEARCH+=$OKAY_SEARCH$'\n'
                    fi
                done
                if [ -z "$ALL_SEARCH" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}没有发现包含'${COLOR_36}${INPUT_PKGE_NAME}${COLOR_33}'的包名${COLOR_0}"
                    REBOOT_FL
                else
                    echo -e -n "${COLOR_35}[NUM]${COLOR_33}输入选定序号(多选以'${COLOR_36}-${COLOR_33}'符号分隔)*ᐷ${COLOR_01}"
                    read INPUT_PKGE_NUMBER
                fi
                if [ -z "$INPUT_PKGE_NUMBER" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                    REBOOT_FL
                else
                    INPUT_PKGE_NUMBER="$(sed 's/-/p;/g' <<< "$INPUT_PKGE_NUMBER")"
                    USR_OKAY_PKGE=$(sed -n "$INPUT_PKGE_NUMBER"p <<< "$ALL_SEARCH")
                fi
                echo -e "${COLOR_35}[USR]${COLOR_33}已选定应用列表 >>${COLOR_0}"
                echo -e "${COLOR_36}$USR_OKAY_PKGE${COLOR_0}"
                echo
                echo -e "${COLOR_35}[>>]${COLOR_33}是否继续操作:${COLOR_36}$MISHUI_MAIN_TIP${COLOR_33} >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›继续操作/2›取消并返回主页]*ᐷ${COLOR_0}"
                read START_YN_APP
                case "$START_YN_APP" in
                '1' | 'y' | 'Y')
                    echo -e "${COLOR_30}"
                    ;;
                *)
                    MAIN_REBOOT
                    ;;
                esac
            }
            ALL_TIP_TION="${COLOR_35}[APP]${COLOR_33}选择对目标设备应用的管理功能 >>${COLOR_0}"
            ICE_THE_USR_APPS() {
                while IFS= read -r ICE_THE_APP
                do
                    if $THE_ICE_CMD "$ICE_THE_APP" </dev/null
                    then
                       echo -e "${COLOR_32}[OKAY]${COLOR_33}应用'${COLOR_36}$ICE_THE_APP${COLOR_33}'$THE_ICE_USR成功${COLOR_0}"
                    else
                       echo -e "${COLOR_31}[ERROR]${COLOR_33}应用'${COLOR_36}$ICE_THE_APP${COLOR_33}'$THE_ICE_USR失败${COLOR_0}"
                        echo -e "${COLOR_35}[Tip]${COLOR_33}检查设备是否正确连接或手动执行命令 >>${COLOR_0}"
                        echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb shell pm disable-user $ICE_THE_APP${COLOR_0}"
                    fi
                done <<< "$USR_OKAY_PKGE"
                REBOOT_FL
            }
            ALL_OPTION=("1*-冻结/解冻选定应用" "2*-安装APK/卸载选定应用" "3*-打开/关闭选定应用" "4*-提取选定应用Apk至本机" "5*-返回主页")
            OPTION_NUB=5
            NOW_LINE
            SHOW_FUNC_MENU
            case "$FUNC_CONT" in
            '1')
                echo -e "${COLOR_35}[ICE]${COLOR_33}选择需要对选定应用进行的冻结/解冻操作 >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›冻结选定应用/2›解冻选定应用]*ᐷ${COLOR_0}"
                read YN_ICE_USR
                case "$YN_ICE_USR" in
                '1' | '冻结' | '冻结选定应用')
                    MISHUI_MAIN_TIP=冻结选定应用
                    THE_ICE_USR='冻结'
                    THE_ICE_CMD='adb shell pm disable-user'
                    ;;
                '2' | '解冻' | '解冻选定应用')
                    MISHUI_MAIN_TIP=解冻选定应用
                    THE_ICE_USR='解冻'
                    THE_ICE_CMD='adb shell pm enable'
                    ;;
                *)
                    if [ -z "$YN_ICE_USR" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                        sleep 0.3
                        MAIN_REBOOT
                    fi
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$YN_ICE_USR${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL
                    ;;
                esac
                SEE_USB_DEVICES
                SEARCH_THE_NEED_APPS
                ICE_THE_USR_APPS
                REBOOT_FL
                ;;
            '2')
                echo -e "${COLOR_35}[IU]${COLOR_33}选择需要进行的安装/卸载操作 >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›安装APK/2›卸载选定应用]*ᐷ${COLOR_01}"
                read UNINSTALL_YN
                case "$UNINSTALL_YN" in
                '1' | '安装' | '安装APK')
                    MISHUI_MAIN_TIP=安装APK
                    SEE_USB_DEVICES
                    echo -e "${COLOR_35}[PATH]${COLOR_33}输入需要安装的apk文件位于本机的完整路径 >>${COLOR_0}"
                    echo -e -n "${COLOR_33}*ᐷ${COLOR_01}"
                    read APK_INSTALL_PATH
                    INSTALL_APK_NAMR="$(basename "$APK_INSTALL_PATH")"
                    if [ -z "$APK_INSTALL_PATH" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处输入不可为空${COLOR_0}"
                        REBOOT_FL
                    elif [ ! -f "$APK_INSTALL_PATH" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}文件'${COLOR_36}$INSTALL_APK_NAMR${COLOR_33}'不存在${COLOR_0}"
                        REBOOT_FL
                    fi
                    echo -e "${COLOR_35}[Installing]${COLOR_33}正在安装'${COLOR_36}$INSTALL_APK_NAMR${COLOR_33}'...${COLOR_30}"
                    if adb install "$APK_INSTALL_PATH" </dev/null
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}APK安装成功${COLOR_0}"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}APK安装失败${COLOR_0}"
                        echo -e "${COLOR_35}[Tip]${COLOR_33}检查设备是否正确连接或手动执行命令 >>${COLOR_0}"
                        echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb install $APK_INSTALL_PATH${COLOR_0}"
                    fi
                    ;;
                '2' | '卸载' | '卸载选定应用')
                    MISHUI_MAIN_TIP=卸载选定应用
                    SEE_USB_DEVICES
                    SEARCH_THE_NEED_APPS
                    while IFS= read -r UN_THE_APP
                    do
                        echo -e "${COLOR_35}[Uninstalling]${COLOR_33}正在卸载'${COLOR_36}$UN_THE_APP${COLOR_33}'...${COLOR_30}"
                        if adb shell pm enable "$UN_THE_APP" </dev/null && adb uninstall "$UN_THE_APP" </dev/null
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}应用'${COLOR_36}$UN_THE_APP${COLOR_33}'卸载成功${COLOR_0}"
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}应用'${COLOR_36}$UN_THE_APP${COLOR_33}'卸载失败${COLOR_0}"
                            echo -e "${COLOR_35}[Tip]${COLOR_33}检查设备是否正确连接或手动执行命令 >>${COLOR_0}"
                            echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb uninstall -k $ICE_THE_APP${COLOR_0}"
                        fi
                    done <<< "$USR_OKAY_PKGE"
                    REBOOT_FL
                    ;;
                *)
                    if [ -z "$UNINSTALL_YN" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                        sleep 0.3
                        MAIN_REBOOT
                    fi
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$UNINSTALL_YN${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL
                    ;;
                esac
                REBOOT_FL
                ;;
            '3')
                echo -e "${COLOR_35}[SK]${COLOR_33}选择需要进行的打开/关闭操作 >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›打开选定应用/2›关闭选定应用]*ᐷ${COLOR_01}"
                read KILL_YN_START
                case "$KILL_YN_START" in
                '1' | '打开选定应用' | '打开')
                    MISHUI_MAIN_TIP=打开选定应用
                    SEE_USB_DEVICES
                    SEARCH_THE_NEED_APPS
                    while IFS= read -r START_THE_APP
                    do
                        echo -e "${COLOR_35}[ACT]${COLOR_33}正在获取'${COLOR_36}$START_THE_APP${COLOR_33}'的Activity...${COLOR_0}"
                        if APP_S_ACTIVITY=$(adb shell cmd package resolve-activity --brief "$START_THE_APP" </dev/null | tail -n 1) && [ -n "$APP_S_ACTIVITY" ]
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}Activity获取成功:${COLOR_36}$APP_S_ACTIVITY${COLOR_0}"
                            echo -e "${COLOR_35}[Starting]${COLOR_33}正在打开'${COLOR_36}$START_THE_APP${COLOR_33}'...$COLOR_30"
                            if adb shell am start -n "$APP_S_ACTIVITY" </dev/null
                            then
                                echo -e "${COLOR_32}[OKAY]${COLOR_33}应用打开成功${COLOR_0}"
                            else
                                echo -e "${COLOR_31}[ERROR]${COLOR_33}应用打开失败${COLOR_0}"
                                echo -e "${COLOR_35}[Tip]${COLOR_33}尝试在被连接设备上手动抓取Activity并手动执行命令 >>${COLOR_0}"
                                echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb shell am start -n $START_THE_APP/<Activity>${COLOR_0}"
                            fi
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}应用'${COLOR_36}$ICE_THE_APP${COLOR_33}'Activity获取失败${COLOR_0}"
                        fi
                    done <<< "$USR_OKAY_PKGE"
                    REBOOT_FL
                    ;;
                '2' | '关闭选定应用' | '关闭')
                    MISHUI_MAIN_TIP=关闭选定应用
                    SEE_USB_DEVICES
                    SEARCH_THE_NEED_APPS
                    while IFS= read -r KILL_THE_APP
                    do
                        echo -e "${COLOR_35}[KILL]${COLOR_33}正在杀死'${COLOR_36}$KILL_THE_APP${COLOR_33}'的全部进程...${COLOR_30}"
                        if adb shell am force-stop "$KILL_THE_APP" </dev/null
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}已成功杀死'${COLOR_36}$KILL_THE_APP${COLOR_33}'的全部进程${COLOR_0}"
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}进程关闭失败 检查是否正确与目标设备连接${COLOR_0}"
                        fi
                    done <<< "$USR_OKAY_PKGE"
                    REBOOT_FL
                    ;;
                *)
                    if [ -z "$KILL_YN_START" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                        sleep 0.3
                        MAIN_REBOOT
                    fi
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$KILL_YN_START${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL
                    ;;
                esac
                ;;
            '4')
                MISHUI_MAIN_TIP=提取应用Apk至本机
                SEE_USB_DEVICES
                SEARCH_THE_NEED_APPS
                echo -e "${COLOR_35}[DL]${COLOR_33}输入欲存放提取的Apk文件的文件夹路径(留空自动存储至'${COLOR_36}Download${COLOR_33}'文件夹) >>${COLOR_0}"
                echo -e -n "${COLOR_33}*ᐷ${COLOR_01}"
                read THE_DOWNLOAD_PATH
                if [ -z "$THE_DOWNLOAD_PATH" ] && [ ! -d "$THE_DOWNLOAD_PATH" ]
                then
                    echo -e "${COLOR_35}[PATH]${COLOR_33}提取的Apk文件将自动存储至'${COLOR_36}/storage/emulated/0/Download/${COLOR_33}'文件夹中${COLOR_0}"
                    THE_DOWNLOAD_PATH='/storage/emulated/0/Download'
                else
                    echo -e "${COLOR_35}[PATH]${COLOR_33}提取的Apk文件将存储至'${COLOR_36}$THE_DOWNLOAD_PATH${COLOR_33}'文件夹中${COLOR_0}"
                    THE_DOWNLOAD_PATH="${THE_DOWNLOAD_PATH%/}"
                fi
                THE_BASE_NUMBER=1
                while IFS= read PULL_THE_APK
                do
                    echo -e "${COLOR_35}[DATA]${COLOR_33}正在获取'${COLOR_36}$PULL_THE_APK${COLOR_33}'的APK文件路径...${COLOR_0}"
                    if THE_APK_PULL_PATH="$(adb shell pm path "$PULL_THE_APK" </dev/null 2>/dev/null | sed 's/package://')" && [ -n "$THE_APK_PULL_PATH" ]
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}路径已获取 正在提取apk...${COLOR_30}"
                        if adb pull "$THE_APK_PULL_PATH" "$THE_DOWNLOAD_PATH/base$THE_BASE_NUMBER.apk" </dev/null
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}已成功将'${COLOR_36}$PULL_THE_APK${COLOR_33}'应用的Apk文件提取至本机路径:${COLOR_36}$THE_DOWNLOAD_PATH/base$THE_BASE_NUMBER.apk${COLOR_0}"
                            THE_BASE_NUMBER=$((THE_BASE_NUMBER + 1))
                            continue
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}APK文件提取失败 尝试手动复制APK文件${COLOR_0}"
                        fi
                        continue
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}路径获取失败 尝试手动定位并复制APK文件${COLOR_0}"
                        continue
                    fi
                done <<< "$USR_OKAY_PKGE"
                REBOOT_FL
                ;;
            '5')
                MAIN_REBOOT
                ;;
            *)
                ERROR_CONT
                ;;
            esac
            ;;
        '3' | 'CMD' | '自定义ADBShell命令')
            MISHUI_MAIN_TIP=自定义ADBShell命令
            SEE_USB_DEVICES
            echo -e "${COLOR_35}[CMD]${COLOR_33}输入可运行于'${COLOR_36}adb${COLOR_33}'的命令 输入'${COLOR_36}exit${COLOR_33}'即可退出${COLOR_0}"
            while true
            do
                echo -e -n "${COLOR_35}[>_]${COLOR_33}输入命令:${COLOR_32}adb ${COLOR_01}"
                read ADB_SHELL_CMD
                if [ -z "$ADB_SHELL_CMD" ]
                then
                    continue
                elif [[ "$ADB_SHELL_CMD" == exit* ]]
                then
                    REBOOT_FL
                else
                    if [[ "$ADB_SHELL_CMD" == abc* ]]
                    then
                        ADB_SHELL_CMD="${ADB_SHELL_CMD#adb}"
                    fi
                    if eval "adb $ADB_SHELL_CMD"
                    then
                        echo -e "${COLOR_32} - 执行成功${COLOR_0}"
                    else
                        echo -e "${COLOR_31} - 执行失败${COLOR_0}"
                    fi
                    continue
                fi
            done
            REBOOT_FL
            ;;
        '4' | 'SET' | '高级系统设置')
            MISHUI_MAIN_TIP=高级系统设置
            MISHUI_MAIN
            echo
            ALL_TIP_TION="${COLOR_35}[SET]${COLOR_33}选择对目标设备的设置/修改项 >>${COLOR_0}"
            ALL_OPTION=("1*-修改/恢复目标设备屏幕比例" "2*-设置目标设备墓碑模式" "3*-返回主页")
            OPTION_NUB=4
            NOW_LINE
            SHOW_FUNC_MENU
            case "$FUNC_CONT" in
            '1')
                MISHUI_MAIN_TIP=修改/恢复屏幕分辨率
                SEE_USB_DEVICES
                SAVE_THE_NEW_SIZE() {
                    if ! BAK_ADB_SIZE="$(adb shell wm size 2>/dev/null | sed 's/.*size: //g')" && [ -z "$BAK_ADB_SIZE" ]
                    then
                        echo -e "${COLOR_35}[WARN]${COLOR_31}无法备份目标设备当前屏幕分辨率 继续执行可能含有风险${COLOR_33} 是否继续 >>${COLOR_0}"
                        echo -e "${COLOR_36}[+][1›确认风险并继续/2›取消并返回主页]*ᐷ${COLOR_01}"
                        read CONTINUE_SET_SIZE
                        case "$CONTINUE_SET_SIZE" in
                            '1' | 'y' | 'Y')
                            echo -e "${COLOR_32}[CONTINUE]${COLOR_33}已确认继续操作 >>${COLOR_0}"
                            ;;
                        *)
                            MAIN_REBOOT
                            ;;
                        esac
                    fi
                    echo -e "${COLOR_35}[BAK]${COLOR_33}已备份当前屏幕分辨率:${COLOR_36}$BAK_ADB_SIZE${COLOR_0}"
                }
                SET_THE_BAK_SIZE() {
                    echo -e "${COLOR_35}[Restoring]${COLOR_33}正在将目标设备恢复至'$COLOR_36$BAK_ADB_SIZE${COLOR_33}'分辨率...${COLOR_30}"
                    if adb shell wm size $BAK_ADB_SIZE
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}原分辨率恢复成功:${COLOR_36}$BAK_ADB_SIZE${COLOR_0}"
                        REBOOT_FL
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}原分辨率恢复失败${COLOR_0}"
                        echo -e "${COLOR_35}[Tip]${COLOR_33}尝试手动执行命令以恢复 必要/极端情况下可前往'${COLOR_36}主页>ADB调试工具>重启连接设备>重启至系统模式${COLOR_33}'工具强制重启目标设备以恢复${COLOR_0}"
                        REBOOT_FL
                    fi
                }
                echo -e "${COLOR_35}[DPI]${COLOR_33}可恢复/修改目标设备的屏幕分辨率(比例) >>${COLOR_0}"
                if [ -n "$BAK_ADB_SIZE" ]
                then
                    echo -e "${COLOR_35}[BAK]${COLOR_33}发现备份的屏幕分辨率:${COLOR_36}$BAK_ADB_SIZE${COLOR_33} 是否恢复至该分辨率 >>${COLOR_0}"
                    echo -e "${COLOR_36}[+][1›恢复该分辨率/2›设置新分辨率]*ᐷ${COLOR_01}"
                    read YN_TO_BAK_SIZE
                    case "$YN_TO_BAK_SIZE" in
                    '1' | 'y' | 'Y')
                        SET_THE_BAK_SIZE
                        ;;
                    *)
                        echo -e "${COLOR_35}[SAVE]${COLOR_33}是否保留最初备份的分辨率:${COLOR_36}$BAK_ADB_SIZE${COLOR_0}"
                        echo -e "${COLOR_36}[+][1›保留原分辨率/2›备份当前分辨率]*ᐷ${COLOR_01}"
                        read SAVE_THE_NEW_YN
                        case "$SAVE_THE_NEW_YN" in
                        '1' | 'y' | 'Y')
                            echo -e "${COLOR_35}[TURE]${COLOR_33}已保留原分辨率:${COLOR_36}$BAK_ADB_SIZE${COLOR_0}"
                            ;;
                        *)
                            SAVE_THE_NEW_SIZE
                            ;;
                        esac
                        ;;
                    esac
                else
                    SAVE_THE_NEW_SIZE
                fi
                echo -e "${COLOR_33}[SIZE]${COLOR_33}输入欲设置的屏幕分辨率(比例) >>${COLOR_0}"
                echo -e -n "[格式:${COLOR_36}1080/2400${COLOR_33}]:${COLOR_01}"
                read SETTING_SIZE
                TIP_THE_ECHO_SIZE="${COLOR_35}[Setting]${COLOR_33}正在将目标设备分辨率设置为'${COLOR_36}$SETTING_SIZE${COLOR_33}'...${COLOR_30}"
                case "$SETTING_SIZE" in
                *[0-9]x[0-9]*)
                    echo -e "$TIP_THE_ECHO_SIZE"
                    ;;
                *[0-9]/[0-9]*)
                    SETTING_SIZE="$(sed 's|/|x|g' <<< "$SETTING_SIZE")"
                    echo -e "$TIP_THE_ECHO_SIZE"
                    ;;
                *[0-9]×[0-9]*)
                    SETTING_SIZE="$(sed 's/×/x/g' <<< "$SETTING_SIZE")"
                    echo -e "$TIP_THE_ECHO_SIZE"
                    ;;
                *)
                    echo -e "${COLOR_31}[!]${COLOR_33}无法识别的格式:${COLOR_36}$SETTING_SIZE${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_33}输入必须为'${COLOR_36}1080/1920${COLOR_33}'或'${COLOR_36}1080x1920${COLOR_33}'或'${COLOR_36}1080×1920${COLOR_33}'三种格式${COLOR_0}"
                    REBOOT_FL
                    ;;
                esac
                if adb shell wm size $SETTING_SIZE
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}设置成功 现在测试目标设备能否正常操作触摸并依据测试结果选择操作 >>${COLOR_0}"
                    echo -e "${COLOR_36}[+][1›屏幕正常并确认修改/2›屏幕失效立即恢复]*ᐷ${COLOR_01}"
                    read INPUT_THE_SIZE_YN
                    case "$CONTINUE_SET_SIZE" in
                    '1' | 'y' | 'Y')
                        echo -e "${COLOR_32}[DONE]${COLOR_33}操作已全部完成 目标设备原始分辨率(${COLOR_36}$BAK_ADB_SIZE${COLOR_33})已保存至当前进程 在未重启/未结束运行脚本前均可通过再次进入该功能恢复原分辨率${COLOR_0}"
                        ;;
                    *)
                        SET_THE_BAK_SIZE
                        ;;
                    esac
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}设置失败 尝试手动执行命令 >>${COLOR_0}"
                    echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb shell wm size $SETTING_SIZE${COLOR_0}"
                    REBOOT_FL
                fi
                ;;
            '2')
                MISHUI_MAIN_TIP=设置墓碑模式
                SEE_USB_DEVICES
                START_OUT_THE_PAS() {
                    echo -e "${COLOR_35}[$3]${COLOR_33}是否$2墓碑模式 >>${COLOR_0}"
                    echo -e "${COLOR_36}[+][1›$2墓碑模式/2›保持现状并返回主页]*ᐷ${COLOR_01}"
                    read FALSE_PAS
                    case "$FALSE_PAS" in
                    '1' | 'y' | 'Y')
                        if adb shell settings put global cached_apps_freezer "$1"
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}已修改 重启后生效${COLOR_0}"
                            echo -e "${COLOR_35}[RE]${COLOR_33}重启:${COLOR_36}主页>ADB调试工具>重启连接设备>重启至系统${COLOR_0}"
                            REBOOT_FL
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}修改失败 尝试手动执行命令${COLOR_0}"
                            echo -e "${COLOR_35}[CMD]${COLOR_33}命令:${COLOR_36}adb shell settings put global cached_apps_freezer $1${COLOR_0}"
                            REBOOT_FL
                        fi
                        ;;
                    *)
                        MAIN_REBOOT
                        ;;
                    esac
                }
                echo -e -n "${COLOR_35}[PAS]${COLOR_33}正在检查目标设备是否支持墓碑模式(${COLOR_36}暂停执行已缓存的应用${COLOR_33}):${COLOR_0}"
                case "$(adb shell settings get global cached_apps_freezer)" in
                'enabled')
                    echo -e "${COLOR_32}设备支持并已启用${COLOR_0}"
                    START_OUT_THE_PAS 'disabled' '关闭' 'TURE'
                    ;;
                'disabled')
                    echo -e "${COLOR_32}设备支持但未启用${COLOR_0}"
                    START_OUT_THE_PAS 'enabled' '开启' 'FALSE'
                    ;;
                *)
                    echo -e "${COLOR_31}设备不支持${COLOR_0}"
                    REBOOT_FL
                    ;;
                esac
                ;;
            '3')
                MAIN_REBOOT
                ;;
            *)
                ERROR_CONT
                ;;
            esac
            REBOOT_FL
            ;;
        '5' | 'RE' | '重启连接设备')
            MISHUI_MAIN_TIP=重启连接设备
            SEE_USB_DEVICES
            ALL_TIP_TION="${COLOR_35}[RE]${COLOR_33}选择需要重启的目标模式 >>${COLOR_0}"
            REBOOT_USB_DEVICES
            ;;
        '6' | 'HOME' | '返回主页')
            MAIN_REBOOT
            ;;
        *)
            if [ -z "$FUNC_CONT" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                sleep 0.3
                MAIN_REBOOT
            fi
            echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$FUNC_CONT${COLOR_33}'非菜单中的选项${COLOR_0}"
            REBOOT_FL
            ;;
        esac
        ;;
    '4' | 'UBL' | '解锁BL锁(第三方工具')
        ADB_FASTBOOT_NAME=FASTBOOT
        ADB_FASTBOOT_CMD=fastboot
        MISHUI_MAIN_TIP=BootLoader解锁
        MISHUI_MAIN
        echo -e "${COLOR}[UBL]${COLOR_33}支持为1加/小米设备解锁BootLoader锁 >>${COLOR_0}"
        echo
        WARN_UNLOCK_BL() {
            echo -e "${COLOR_35}[WARN]${COLOR_31}解锁设备的BootLoader锁将使设备失去保修/安全性下降 ${COLOR_33}是否继续 >>${COLOR_0}"
            echo -e -n "${COLOR_36}[+][1›已知晓并继续/2›立即中断并退出]*ᐷ${COLOR_01}"
            read UNLOCK_BOOTLOADER_YN
            case "$UNLOCK_BOOTLOADER_YN" in
            '1' | 'y' | 'Y')
                echo -e "${COLOR_35}[INFO]${COLOR_33}即将开始解锁 确保目标设备已开启'${COLOR_36}OEM解锁${COLOR_33}'选项${COLOR_0}"
                ;;
            *)
                MAIN_REBOOT
                ;;
            esac
        }
        ALL_TIP_TION="${COLOR_35}[DEV]${COLOR_33}选择目标设备类型 >>${COLOR_0}"
        ALL_OPTION=("1*-一加/OnePlus-命令解锁" "2*-Xiaomi/Redmi-第三方工具解锁" "3*-返回主页")
        OPTION_NUB=3
        NOW_LINE
        SHOW_FUNC_MENU
        case "$FUNC_CONT" in
        '1')
            MISHUI_MAIN_TIP=解锁一加/OnePlus
            SEE_USB_DEVICES
            WARN_UNLOCK_BL
            echo -e "${COLOR_35}[Unlocking]${COLOR_33}正在使用'${COLOR_36}fastboot flashing unlock${COLOR_33}'命令解锁...${COLOR_0}"
            if fastboot flashing unlock
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}命令执行成功${COLOR_0}"
                echo -e "${COLOR_35}[Tip]${COLOR_33}目标设备跳转页面后点击目标设备'${COLOR_36}音量-${COLOR_33}'键选择'${COLOR_36}UNLOCK THE BOOTLOADER${COLOR_33}'选项并使用关机键确定即可完成解锁${COLOR_0}"
                REBOOT_FL
            esle
                echo -e "${COLOR_31}[ERROR]${COLOR_33}命令执行失败 可能因为Termux没有足够权限${COLOR_0}"
                REBOOT_FL
            fi
            ;;
        '2')
            MISHUI_MAIN_TIP=解锁Xiaomi/Redmi
            SEE_USB_DEVICES
            WARN_UNLOCK_BL
            INSTALL_ITS_CMD="curl -sS https://raw.githubusercontent.com/offici5l/MiUnlockTool/refs/heads/main/.install | bash"
            NOT_INSTALL_TOOLS='MiUnlockTool'
            NOT_INSTALL_CMD='miunlock'
            INSTALL_THE_NUST_CMD
            echo -e "${COLOR_35}[START]${COLOR_33}即将进入第三方工具解锁页面${COLOR_0}"
            echo -e "${COLOR_35}(</>)${COLOR_33}工具来源:${COLOR_36}Telegram${COLOR_32} @Offici5l_Channel${COLOR_0}"
            sleep 0.5
            miunlock
            echo -e "${COLOR_35}[BACK]${COLOR_33}已返回脚本${COLOR_0}"
            REBOOT_FL
            ;;
        '3')
            MAIN_REBOOT
            ;;
        *)
            ERROR_CONT
            ;;
        esac
        ;;
    '5' | '安装第三方Termux-Fastboot&ADB工具' | 'ISNT')
        MISHUI_MAIN_TIP='安装第三方F&A工具'
        MISHUI_MAIN
        echo
        echo -e "$COLOR[INST]${COLOR_33}安装更好用的第三方${COLOR_36}ADB&Fastboot${COLOR_33}命令 >>${COLOR_0}"
        ADB_FASTBOOT_VER
        echo -e "${COLOR_35}[NE]${COLOR_33}是否立即安装第三方${COLOR_36}ADB&Fastboot${COLOR_33}命令 >>${COLOR_0}"
        echo -e -n "${COLOR_36}[+][1›立即安装/2›返回主页]*ᐷ${COLOR_01}"
        read YN_UPDATE
        case "$YN_UPDATE" in
        '1' | 'y' | 'Y')
            echo -e "${COLOR_35}[Tip]${COLOR_33}长时间未开始安装尝试连接魔法安装${COLOR_0}"
            echo
            echo -e "${COLOR_35}[Installing]${COLOR_33}正在安装第三方${COLOR_36}ADB&Fastboot${COLOR_33}命令...${COLOR_0}"
            if NOW_LINE && curl -sS 'https://raw.githubusercontent.com/offici5l/termux-adb-fastboot/refs/heads/main/install' | bash && CLEAR_LINE
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}工具包'${COLOR_36}ADB&Fastboot${COLOR_33}'安装成功${COLOR_0}"
                ADB_FASTBOOT_VER
                REBOOT_FL
            else
                EXIT_CODE="$?"
                echo -e "${COLOR_31}[ERROR]${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}安装失败 尝试手动执行命令 >>${COLOR_0}"
                echo -e "${COLOR_33} - 命令: ${COLOR_36}$INSTALL_ITS_CMD${COLOR_0}"
                REBOOT_FL
            fi
            ;;
        *)
            MAIN_REBOOT
            ;;
        esac
        ;;
    '6' | '重启MST工具箱' | 'RE')
        echo -e -n "${COLOR}[MST]${COLOR_33}重启MiShuiTool...${COLOR_0}"
        sleep 0.4
        exec bash "$0"
        ;;
    '7' | '退出MST工具箱' | 'EXIT')
        EXIT_SHELL
        ;;
    *)
        if [ -z "$INPUT_USR" ]
        then
            echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
            sleep 0.3
            MAIN_REBOOT
        fi
        echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$INPUT_USR${COLOR_33}'非菜单中的选项${COLOR_0}"
        REBOOT_FL
    ;;
    esac
}
CA_FLASH_MAIN