#!/data/data/com.termux/files/usr/bin/bash
bash -c true; export COLOR_RM="\033[9m"
export COLOR_30="\033[0;30;1m"; export COLOR_31="\033[0;31;1m"
export COLOR_32="\033[0;32;1m"; export COLOR_33="\033[0;33;1m"
export COLOR_34="\033[0;34;1m"; export COLOR_35="\033[0;35;1m"
export COLOR_36="\033[0;36;1m"; export COLOR_37="\033[0;37;1m"
export COLOR_0="\033[0m"; export COLOR_01="\033[0;1m"
STORAGE=/storage/emulated/0
MST_HOME="$HOME/MST"
MST_LOG="$MST_HOME/MST运行日志.log"
DOWNLOAD_PATH=$STORAGE/Download
TERMUX_CMD_PATH=/data/data/com.termux/files/usr/bin
MST_UPDATE_TIME='2026.2.21 Beta'
NOW_VERSION=10004
if [ "$(id -u)" = "0" ]
then
    export COLOR="$COLOR_31"
else
    export COLOR="$COLOR_36"
fi
CLEAR_LINE() {
    echo -e -n "\033[$NOW_LINE;1H"
    echo -e -n "\033[J"
}
SHOW_FUNC_MENU() {
    local ALL_CON ALL_INPUT
    local OPTION_NUB=${#ALL_OPTION[@]}
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
        case "$ALL_CON" in
        "A")
            FUNC_CONT=$((FUNC_CONT - 1))
            if [ $FUNC_CONT -lt 0 ]
            then
                FUNC_CONT=$((${#ALL_OPTION[@]} - 1))
            fi
            ;;
        "B")
            FUNC_CONT=$((FUNC_CONT + 1))
            if [ $FUNC_CONT -ge ${#ALL_OPTION[@]} ]
            then
                FUNC_CONT=0
            fi
            ;;
        [1-$OPTION_NUB])
            FUNC_CONT=$((ALL_CON - 1))
            ;;
        "")
            break
            ;;
        esac
    done
    FUNC_CONT=$((FUNC_CONT + 1))
    echo
    echo -e "${COLOR_37}------------------------------------—${COLOR_0}"
}
ENTER_ANY_CONTINUE() {
    echo
    echo -e -n "${COLOR_35}[Enter]${COLOR_33}完成后点按任意键继续${COLOR_0}"
    read -s -n1
    echo
}
CLEAR_READ_INPUT() {
    while read -r -t 0
    do
        read -r
    done
}
ERROR_CONT() {
    echo -e "${COLOR_31}[!]${COLOR_33}异常选项:${COLOR_36}$FUNC_CONT${COLOR_0}"
    REBOOT_FL || return 0
}
ALL_REBOOT() {
    CLEAR_READ_INPUT
    sleep 0.4
    CA_FLASH_MAIN
    return 0
}
REBOOT_FL() {
    echo
    echo -e -n "${COLOR}[MST]${COLOR_33}点按回车返回主页${COLOR_0}"
    read -s
    echo
    echo -e -n "${COLOR_34}[BACK]${COLOR_33}返回主页...${COLOR_0}"
    ALL_REBOOT || return 0
}
SU_REBOOT_FL() {
    echo
    echo -e -n "${COLOR}[MST]${COLOR_33}返回主页...${COLOR_0}"
    ALL_REBOOT || return 0
}
MAIN_REBOOT() {
    echo -e -n "${COLOR}[MST]${COLOR_33}返回主页...${COLOR_0}"
    ALL_REBOOT || return 0
}
EXIT_SHELL() {
    local EXIT_CODE="${1:-0}"
    echo -e "${COLOR_35}[EXIT]${COLOR_33}退出脚本(退出码:${COLOR_36}$EXIT_CODE${COLOR_33})...${COLOR_0}"
    exit "$EXIT_CODE"
}
BACK_TO_SHELL() {
    local EXIT_YN
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
START_CMD_TIME() {
    CMD_START=$(date +%s.%N)
}
END_CMD_TIME() {
    CMD_END=$(date +%s.%N)
    ALL_CMD_TIME=$(awk "BEGIN {printf \"%.2f\", $CMD_END - $CMD_START}")
}
SELEC_ADB_FB_DEVICE() {
    unset SELEC_USR_DEVICE
    local ONE_USR_DEV THE_SELEC_DEV_NUM SELE_NEED_DEVICES
    local ONE_ADB_DEVICE ONE_DEVICE USR_OKAY_DEVICES
    local ALL_SEARCH="$2"
    echo -e "${COLOR_32}连接多台设备 >>${COLOR_0}"
    local USR_DEVICES_NUM=1
    while IFS= read -r ONE_USR_DEV
    do
        echo -e -n "${COLOR_33}›$USR_DEVICES_NUM*-${COLOR_32}$ONE_USR_DEV${COLOR_0} "
        case "$1" in
        'adb')
            if ONE_DEVICE="$(adb -s "$ONE_USR_DEV" shell settings get global device_name </dev/null 2>>$MST_LOG)" && [ -n "$ONE_DEVICE" ]
            then
                echo -e "${COLOR_33}(${COLOR_36}$ONE_DEVICE${COLOR_33})${COLOR_0}"
            else
                echo -e "${COLOR_33}(${COLOR_31}未知${COLOR_33})${COLOR_0}"
            fi
            ;;
        *)
            echo
            ;;
        esac
        USR_DEVICES_NUM=$((USR_DEVICES_NUM + 1))
    done <<< "$ADB_DEVICES"
    case "$1" in
    'adb')
        echo -e "${COLOR_35}[SELE]${COLOR_33}输入要选择的设备序号(多选以'${COLOR_36}-${COLOR_33}'符号分隔)${COLOR_0}"
        echo -e -n "${COLOR_33}*ᐷ ${COLOR_01}"
        read SELE_NEED_DEVICES
        if [[ "$SELE_NEED_DEVICES" =~ ^[0-9]+(-[0-9]+)*$ ]]
        then
            USR_OKAY_DEVICES="$(sed -n "$(sed 's/-/p;/g' <<< "${SELE_NEED_DEVICES%%-}")p" <<< "$ALL_SEARCH")"
        elif [[ "$SELE_NEED_DEVICES" =~ ^[0-9]+$ ]]
        then
            USR_OKAY_DEVICES="$(sed -n ${SELE_NEED_DEVICES}p <<< "$ALL_SEARCH")"
        else
            echo -e "${COLOR_31}[!]${COLOR_33}无法解析的输入(${COLOR_36}$SELE_NEED_DEVICES${COLOR_33}) 若要多选必须以'${COLOR_36}-${COLOR_36}'符号分隔${COLOR_0}"
            REBOOT_FL || return 0
        fi
        ;;
    'fastboot')
        echo -e -n "${COLOR_35}[SELE]${COLOR_33}输入要选择的设备序号*ᐷ${COLOR_01}"
        read SELE_NEED_DEVICES
        case "$SELE_NEED_DEVICES" in
        [1-9]*)
            USR_OKAY_DEVICES="$(sed -n ${SELE_NEED_DEVICES}p <<< "$ALL_SEARCH")"
            ;;
        *)
            echo -e "${COLOR_31}[!]${COLOR_33}无法解析的输入(${COLOR_36}$SELE_NEED_DEVICES${COLOR_33}) Fastboot设备不支持多选${COLOR_0}"
            REBOOT_FL || return 0
            ;;
        esac
        ;;
    esac
    if [ -z "$USR_OKAY_DEVICES" ]
    then
        echo -e "${COLOR_31}[!]${COLOR_33}无法解析的内容:${COLOR_36}$SELE_NEED_DEVICES${COLOR_0}"
        echo -e "${COLOR_35}[Tip]${COLOR_33}ADB设备支持输入单数字进行单选以及通过'${COLOR_36}-${COLOR_33}'符号分隔数字进行多选 Fastboot设备为了安全仅支持单选${COLOR_0}"
        REBOOT_FL || return 0
    fi
    echo -e "${COLOR_32}[OKAY]${COLOR_33}已选中设备列表 >>${COLOR_0}"
    while IFS= read -r ONE_ADB_DEVICE
    do
        echo -e -n "${COLOR_36}$ONE_ADB_DEVICE${COLOR_0}"
        if THE_ONE_DEVICE_SEE=$(adb -s "$ONE_ADB_DEVICE" shell settings get global device_name </dev/null 2>>$MST_LOG) && [ -n "$THE_ONE_DEVICE_SEE" ]
        then
            echo -e "${COLOR_33}(${COLOR_32}$THE_ONE_DEVICE_SEE${COLOR_33})${COLOR_0}"
        else
            echo -e "${COLOR_33}(${COLOR_31}未知${COLOR_33})${COLOR_0}"
        fi
        SELEC_USR_DEVICE+="$ONE_ADB_DEVICE"
    done <<< "$USR_OKAY_DEVICES"
}
USB_DEVICES_FASTBOOT() {
    echo -e -n "${COLOR_35}[FASTBOOT]${COLOR_33}设备连接状态:${COLOR_0}"
    FASTBOOT_DEVICES="$(fastboot devices 2>&1)"
    if [ -n "$FASTBOOT_DEVICES" ]
    then
        FASTBOOT_DEVICES=$(echo "$FASTBOOT_DEVICES" | awk '/fastboot/ {print $1}')
    elif [ -z "$FASTBOOT_DEVICES" ]
    then
        FASTBOOT_GETVAR="$(timeout 3 fastboot getvar serialno 2>&1 | sed 's/<.*//g')"
        FASTBOOT_DEVICES=$(echo "$FASTBOOT_GETVAR" | grep 'serialno:' | sed 's/serialno://g')
    fi
    if [ -z "$FASTBOOT_DEVICES" ] && [ -z "$FASTBOOT_GETVAR" ]
    then
        echo -e "${COLOR_31}未连接设备${COLOR_0}"
        return 1
    elif [ "$(wc -l <<< "$FASTBOOT_DEVICES")" -ge 2 ]
    then
        SELEC_ADB_FB_DEVICE fastboot "$FASTBOOT_DEVICES"
        SELEC_FASTBOOT_DEVICE="$SELEC_USR_DEVICE"
    else
        SELEC_FASTBOOT_DEVICE="$FASTBOOT_DEVICES"
    fi
    echo -e "${COLOR_36}$SELEC_FASTBOOT_DEVICE fastboot${COLOR_32}-已连接${COLOR_0}"
    FB_DEV_BL="$(fastboot -s "$SELEC_FASTBOOT_DEVICE" getvar unlocked 2>&1 | grep 'unlocked' | sed 's/.*: //g' &>>$MST_LOG)"
    FB_DEV_TOKEN="$(fastboot -s "$SELEC_FASTBOOT_DEVICE" getvar token 2>&1 | grep 'token' | sed 's/.*: //g' &>>$MST_LOG)"
    FB_DEV_SLOT="$(fastboot -s "$SELEC_FASTBOOT_DEVICE" getvar current-slot 2>&1 | grep 'slot' | sed 's/.*slot: //g' &>>$MST_LOG)"
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
    echo
    echo -e "${COLOR_35}[FASTBOOT]${COLOR_33}已连接设备信息 >>${COLOR_0}"
    echo -e "${COLOR_33}设备Token:${COLOR_32}$FB_DEV_TOKEN${COLOR_0}"
    echo -e "${COLOR_33}BL锁状态:${COLOR_32}$FB_DEV_BL${COLOR_0}"
    echo -e "${COLOR_33}当前A/B槽位:$FB_DEV_SLOT${COLOR_0}"
    return 0
}
USB_DEVICES_ADB() {
    local SEE_SOME_LINE
    echo -e -n "${COLOR_35}[ADB]${COLOR_33}设备连接状态:${COLOR_0}"
    timeout 5 adb wait-for-device &>>$MST_LOG
    ALL_ADB_DEVICES="$(adb devices 2>>$MST_LOG)"
    ADB_DEVICES="$(sed '/^$/d; /List/d; s/\s.*//g' <<< "$ALL_ADB_DEVICES")"
    if [ -z "$ADB_DEVICES" ]
    then
        echo -e "${COLOR_31}未连接设备${COLOR_0}"
        return 1
    elif [ "$(wc -l <<< "$ADB_DEVICES")" -gt 1 ]
    then
        SELEC_ADB_FB_DEVICE adb "$ADB_DEVICES"
        SELEC_ADB_DEVICE="$SELEC_USR_DEVICE"
    else
        echo -e "${COLOR_36}$ADB_DEVICES adb${COLOR_32}-已连接${COLOR_0}"
        SELEC_ADB_DEVICE="$ADB_DEVICES"
    fi
    CPU_GHZ=$(adb -s "$SELEC_ADB_DEVICE" shell "MAX_GHZ=\$(cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq | sort -n | tail -1); echo \"scale=2; \$MAX_GHZ / 1000000\" | bc" 2>>$MST_LOG)
    CPUNAME=$(adb -s "$SELEC_ADB_DEVICE" shell grep 'Hardware' /proc/cpuinfo 2>>$MST_LOG | sed 's/.*: //g; s/, /-/g' 2>>$MST_LOG)
    OSV=$(adb -s "$SELEC_ADB_DEVICE" shell getprop ro.build.version.release 2>>$MST_LOG)
    CPUUN=$(adb -s "$SELEC_ADB_DEVICE" shell grep -c "processor" /proc/cpuinfo 2>>$MST_LOG)
    DEVONE=$(adb -s "$SELEC_ADB_DEVICE" shell getprop ro.product.device 2>>$MST_LOG)
    DEVTWO=$(adb -s "$SELEC_ADB_DEVICE" shell settings get global device_name 2>>$MST_LOG)
    UINAME=$(adb -s "$SELEC_ADB_DEVICE" shell getprop ro.build.display.id 2>>$MST_LOG)
    KERNEL=$(adb -s "$SELEC_ADB_DEVICE" shell uname -r 2>>$MST_LOG)
    WIFI=$(adb -s "$SELEC_ADB_DEVICE" shell getprop gsm.version.baseband 2>>$MST_LOG)
    DEV_SDK=$(adb -s "$SELEC_ADB_DEVICE" shell getprop ro.build.version.sdk 2>>$MST_LOG)
    DEV_NAME=$(adb -s "$SELEC_ADB_DEVICE" shell getprop ro.product.brand 2>>$MST_LOG)
    local ALL_ABC=("CPUNAME" "OSV" "CPUUN" "DEVONE" "DEVTWO" "UINAME" "KERNEL" "WIFI" "DEV_SDK" "DEV_NAME" "CPU_GHZ")
    for ABC in "${ALL_ABC[@]}"
    do
        if [ -z "${!ABC}" ]
        then
            declare "$ABC=${COLOR_31}未知${COLOR_32}"
        fi
    done
    echo
    echo -e "${COLOR_35}[ADB]${COLOR_33}已连接设备信息 >>${COLOR_0}"
    echo -e "${COLOR_33}设备:${COLOR_32}$DEV_NAME $DEVTWO ($DEVONE)${COLOR_0}"
    echo -e "${COLOR_33}CPU:${COLOR_32}$CPUNAME ${COLOR_32}($CPUUN核)${COLOR_33}/最大频率:${COLOR_32}$CPU_GHZ ${COLOR_32}GHz${COLOR_0}"
    echo -e "${COLOR_33}内核:${COLOR_32}$KERNEL${COLOR_0}"
    echo -e "${COLOR_33}基带:${COLOR_32}$WIFI${COLOR_0}"
    echo -e "${COLOR_33}系统:${COLOR_32}$UINAME${COLOR_33}/Android${COLOR_32} $OSV (SDK:$DEV_SDK)${COLOR_0}"
    return 0
}
ADB_FASTBOOT_VER() {
    echo -e "${COLOR_35}[ADB]${COLOR_33}当前版本 >>${COLOR_32}"
    adb  --version | grep 'version'
    echo -e "${COLOR_35}[Fastboot]${COLOR_33}当前版本 >>${COLOR_32}"
    fastboot --version | grep 'version'
    echo -e -n "${COLOR_0}\r"
}
REBOOT_USB_DEVICES() {
    local REBOOT_PT REBOOT_NAME REBOOT_TAP
    ALL_OPTION=("1*-重启至FASTBOOT-线刷模式" "2*-重启至RECOVERY-卡刷/恢复模式" "3*-重启至系统" "4*-返回主页")
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
        REBOOT_TAP=''
        ;;
    '4')
        MAIN_REBOOT || return 0
        ;;
    *)
        ERROR_CONT
        ;;
    esac
    echo -e "${COLOR_35}[Rebooting]${COLOR_33}正在将目标设备重启至'${COLOR_36}$REBOOT_NAME${COLOR_33}'模式...${COLOR_30}"
    if $ADB_FASTBOOT_CMD reboot $REBOOT_PT
    then
        echo -e "${COLOR_32}[OKAY]${COLOR_33}已将目标设备重启至'${COLOR_36}$REBOOT_NAME${COLOR_33}'模式${COLOR_0}"
    else
        echo -e "${COLOR_31}[ERROR]${COLOR_33}重启目标设备失败${COLOR_0}"
        echo -e "${COLOR_35}[Tip]${COLOR_33}可长按目标设备'${COLOR_36}关机$REBOOT_TAP键${COLOR_33}'手动重启${COLOR_0}"
    fi
    REBOOT_FL || return 0
}
INSTALL_THE_MUST_CMD() {
    local INSTALL_ITS_CMD="$1"
    local NOT_INSTALL_TOOLS="$2"
    local NOT_INSTALL_CMD="$3"
    if ! command -v $NOT_INSTALL_CMD &>>$MST_LOG
    then
        echo -e "${COLOR_31}[ERROR]${COLOR_33}没有在当前环境(${COLOR_36}$PATH${COLOR_33})中找到'${COLOR_36}$NOT_INSTALL_CMD${COLOR_33}'命令${COLOT_0}"
        echo
        echo -e "${COLOR_35}[GET]${COLOR_33}是否安装'${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}'工具包 >>${COLOR_0}"
        echo -e -n "${COLOR_36}[+][1›立即安装/2›取消并退出]*ᐷ${COLOR_01}"
        read YN_INSTALL_CMD
        case "$YN_INSTALL_CMD" in
        '1' | 'y' | 'Y')
            echo -e "${COLOR_35}[Installing]${COLOR_33}正在安装...${COLOR_0}"
            if bash -c "$INSTALL_ITS_CMD" && CLEAR_READ_INPUT
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}工具包'${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}'安装成功${COLOR_0}"
                REBOOT_FL || return 0
            else
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
    fi
}
SEE_USB_DEVICES() {
    MISHUI_MAIN
    if ! USB_DEVICES_$ADB_FASTBOOT_NAME
    then
        echo -e "${COLOR_31}[!]${COLOR_33}没有设备连接无法继续${COLOR_0}"
        echo -e "${COLOR_35}[Tip]${COLOR_33}在主页中使用'${COLOR_36}连接设备${COLOR_33}'功能连接设备后再试${COLOR_0}"
        REBOOT_FL || return 0
    fi
    echo
}
CONTINUE_YN() {
    echo -e -n "${COLOR_35}[Continue]${COLOR_33}按任意键继续 回车键取消${COLOR_0}"
    read -s -n1 CONTINUE
    echo
}
MAIN_HAED_TIP() {
    clear
    echo -e "${COLOR}[MiShuiTool]${COLOR_33}Termux刷机工具箱${COLOR_36}/MST CLI${COLOR_33} 版本:${COLOR_32}$MST_UPDATE_TIME${COLOR_0}"
    echo -e "${COLOR_37} - *$(shuf -n 1 $MST_HOME/assets/Text/MST-Head.txt 2>>$MST_LOG)${COLOR_0}"
}
MISHUI_MAIN() {
    MAIN_HAED_TIP
    echo -e "${COLOR_35}-M ${COLOR_36}███${COLOR_33}╗${COLOR_36}   ███${COLOR_33}╗${COLOR_36} ██${COLOR_33}╗${COLOR_36} ███████${COLOR_33}╗${COLOR_36}████████${COLOR_33}╗${COLOR_36}██████${COLOR_33}╗${COLOR_36}  ██████${COLOR_33}╗${COLOR_36} ██${COLOR_33}╗${COLOR_36}  ██${COLOR_33}╗${COLOR_0}"
    echo -e "${COLOR_35}-i ${COLOR_36}████${COLOR_33}╗${COLOR_36} ████${COLOR_33}║ ╚═╝ ${COLOR_36}██${COLOR_33}╔════╝╚══${COLOR_36}██${COLOR_33}╔══╝${COLOR_36}██${COLOR_33}╔══${COLOR_36}██${COLOR_33}╗${COLOR_36}██${COLOR_33}╔═══${COLOR_36}██${COLOR_33}╗╚${COLOR_36}██${COLOR_33}╗${COLOR_36}██${COLOR_33}╔╝${COLOR_0}"
    echo -e "${COLOR_35}-S ${COLOR_36}██${COLOR_33}╔${COLOR_36}████${COLOR_33}╔${COLOR_36}██${COLOR_33}║${COLOR_36} ██${COLOR_33}╗${COLOR_36} ███████${COLOR_33}╗${COLOR_36}   ██${COLOR_33}║${COLOR_36}   ██████${COLOR_33}╔╝${COLOR_36}██${COLOR_33}║${COLOR_36}   ██${COLOR_33}║ ╚${COLOR_36}███${COLOR_33}╔╝${COLOR_0}"
    echo -e "${COLOR_35}-h ${COLOR_36}██${COLOR_33}║╚${COLOR_36}██${COLOR_33}╔╝${COLOR_36}██${COLOR_33}║${COLOR_36} ██${COLOR_33}║ ╚════${COLOR_36}██${COLOR_33}║${COLOR_36}   ██${COLOR_33}║${COLOR_36}   ██${COLOR_33}╔══${COLOR_36}██${COLOR_33}╗${COLOR_36}██${COLOR_33}║${COLOR_36}   ██${COLOR_33}║${COLOR_36} ██${COLOR_33}╔${COLOR_36}██${COLOR_33}╗${COLOR_0}"
    echo -e "${COLOR_35}-u ${COLOR_36}██${COLOR_33}║ ╚═╝ ${COLOR_36}██${COLOR_33}║${COLOR_36} ██${COLOR_33}║${COLOR_36} ███████${COLOR_33}║${COLOR_36}   ██${COLOR_33}║${COLOR_36}   ██████${COLOR_33}╔╝╚${COLOR_36}██████${COLOR_33}╔╝${COLOR_36}██${COLOR_33}╔╝${COLOR_36} ██${COLOR_33}╗${COLOR_0}"
    echo -e "${COLOR_35}-i ${COLOR_33}╚═╝     ╚═╝ ╚═╝ ╚══════╝   ╚═╝   ╚═════╝  ╚═════╝ ╚═╝  ╚═╝${COLOR_0}"
    echo -e "${COLOR_30}----------------------------------------------------${COLOR_0}"
    echo -e "$COLOR[MST]${COLOR_33}当前时间:[${COLOR_32}$(date +%Y.%m.%d)${COLOR_33}/${COLOR_32}$(date +%H:%M:%S)${COLOR_33}] $MISHUI_MAIN_TIP >>${COLOR_0}"
}
CA_FLASH_MAIN() {
    MISHUI_MAIN_TIP=MiShuiTool
    MISHUI_MAIN
    if [ ! "$PATH" = /data/data/com.termux/files/usr/bin ]
    then
        echo -e "${COLOR_31}[!]${COLOR_33}当前环境(${COLOR_36}$PATH${COLOR_33})非Termux无法运行${COLOR_0}"
        echo -e "${COLOR_35}[Tip]${COLOR_33}在Termux中使用'${COLOR_36} bash $0 ${COLOR_33}'命令执行脚本${COLOR_0}"
        EXIT_SHELL 
    elif [ ! -d /data/data/com.termux.api ]
    then
        echo -e "${COLOR_31}[!]${COLOR_33}当前还未安装'${COLOR_36}Termux-Api${COLOR_33}'App${COLOR_0}"
        echo -e "${COLOR_35}[Tip]${COLOR_33}访问Termux官网下载Termux-Api并安装:${COLOR_36}https://termux.dev/${COLOR_0}"
    fi
    INSTALL_THE_MUST_CMD 'curl -sS https://raw.githubusercontent.com/offici5l/termux-adb-fastboot/refs/heads/main/install | bash' 'ADB&Fastboot' 'fastboot'
    INSTALL_THE_MUST_CMD 'pkg install termux-api -y' 'Termux-API' 'termux-usb'
    echo -e "${COLOR_35}[DEV]${COLOR_33}›1*-${COLOR_36}管理连接设备${COLOR_35}[FB]${COLOR_33}›2*-${COLOR_36}Fastboot刷机工具${COLOR_0}"
    echo -e "${COLOR_35}[ADB]${COLOR_33}›3*-${COLOR_36}ADB调试工具 ${COLOR_35}[UBL]${COLOR_33}›4*-${COLOR_36}解锁BL锁(第三方工具)${COLOR_0}"
    echo -e "${COLOR_35}[INST]${COLOR_33}›5*-${COLOR_36}安装第三方Termux-Fastboot&ADB工具${COLOR_0}"
    echo -e "${COLOR_35}[&]${COLOR_33}›6*-${COLOR_36}关于/帮助/更新${COLOR_35}[EXIT]${COLOR_33}›7*-${COLOR_36}退出MST工具箱${COLOR_0}"
    echo -e -n "${COLOR}[-${COLOR_32}CA${COLOR}-]${COLOR_33}输入选项*ᐷ${COLOR_0}"
    CLEAR_READ_INPUT
    read INPUT_USR
    echo -e "${COLOR_30}-------------------------------------------------${COLOR_0}"
    case "$INPUT_USR" in
    '1' | 'DEV' | '管理连接设备')
        CNT_ANY_DEVICED() {
            local FASTBOOT_OR_ADB_NAME=$1
            local DEVICES_PATH
            echo
            if USB_DEVICES_$FASTBOOT_OR_ADB_NAME
            then
                case "$2" in
                y)
                    true
                    ;;
                *)
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}$FASTBOOT_OR_ADB_NAME设备已就绪无需重复连接${COLOR_0}"
                    REBOOT_FL || return 0
                    ;;
                esac
            else
                echo -e "${COLOR_35}[>>]${COLOR_33}自动连接设备中...${COLOR_0}"
                if DEVICES_PATH=$(termux-usb -l 2>&1 | grep '/' | sed 's/ //g; s/"//g') && [ -n "$DEVICES_PATH" ]
                then
                    echo -e "${COLOR_35}[USB]${COLOR_33}发现可连接设备:${COLOR_36}$DEVICES_PATH${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_33}已向该设备发送连接请求 10秒内弹窗点击确认${COLOR_0}"
                    timeout 10 termux-usb -r -e $SHELL -E "$DEVICES_PATH"
                    echo -e "${COLOR_35}[CNT]${COLOR_33}验证设备连接...${COLOR_0}"
                    if USB_DEVICES_$FASTBOOT_OR_ADB_NAME
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}设备连接成功${COLOR_0}"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}设备连接失败 重试一次或使用ROOT模式执行${COLOR_0}"
                        REBOOT_FL || return 0
                    fi
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}没有发现可连接设备${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_36}重新插入USB设备${COLOR_33}/${COLOR_36}重启Termux${COLOR_33}/${COLOR_36}检查数据线是否正确连接${COLOR_33}/${COLOR_36}重启目标设备${COLOR_33}以尝试解决问题${COLOR_0}"
                    REBOOT_FL || return 0
                fi
            fi
        }
        REBOOT_THE_ADB() {
            echo -e -n " ${COLOR_35}[SVR]${COLOR_33}重启ADB守护进程...${COLOR_0}\r"
            adb kill-server &>>$MST_LOG && adb start-server &>>$MST_LOG && true
        }
        MISHUI_MAIN_TIP=管理连接设备
        MISHUI_MAIN
        echo
        ALL_TIP_TION="${COLOR}[DEV]${COLOR_33}选择设备管理功能 >>${COLOR_0}"
        ALL_OPTION=("1*-连接FASTBOOT设备" "2*-连接ADB设备" "3*-连接无线调试ADB设备" "4*-返回主页")
        NOW_LINE
        SHOW_FUNC_MENU
        case "$FUNC_CONT" in
        '1')
            MISHUI_MAIN_TIP=连接FASTBOOT设备
            MISHUI_MAIN
            CNT_ANY_DEVICED FASTBOOT
            REBOOT_FL || return 0
            ;;
        '2')
            # REBOOT_THE_ADB
            MISHUI_MAIN_TIP=连接ADB设备
            MISHUI_MAIN
            CNT_ANY_DEVICED ADB
            REBOOT_FL || return 0
            ;;
        '3')
            REBOOT_THE_ADB
            MISHUI_MAIN_TIP=连接无线调试ADB设备
            MISHUI_MAIN
            FASTBOOT_OR_ADB_NAME=ADB
            WARIN_TIP="${COLOR_31}[!]${COLOR_33}输入格式不正确 正确格式应为:${COLOR_36}192.168.00.00:0000${COLOR_0}"
            echo -e "${COLOR_35}[WLAN]${COLOR_33}无线ADB连接必须保证本机与目标设备处于同一Wi-Fi局域网下${COLOR_0}"
            echo
            echo -e "${COLOR_35}[OS]${COLOR_33}选择目标设备的Android系统版本 >>${COLOR_0}"
            echo -e -n "${COLOR_36}[+][1›Android11以上/2›Android11以下]*ᐷ${COLOR_0}"
            read THE_CONNNECT_VERSION
            echo
            case "$THE_CONNNECT_VERSION" in
            '1' | 'Android11以上')
                echo -e "${COLOR_35}[Tip]${COLOR_33}在目标设备上按照以下步骤打开'${COLOR_36}无线调试${COLOR_33}'选项 >>${COLOR_0}"
                echo -e "${COLOR_35}[STEP]${COLOR_36}系统设置 ${COLOR_33}-> ${COLOR_36}开发者选项 ${COLOR_33}->${COLOR_36} 无线调试${COLOR_33} -> ${COLOR_36}使用配对码配对${COLOR_0}"
                ENTER_ANY_CONTINUE
                echo
                echo -e "${COLOR_35}[IP]${COLOR_33}输入'${COLOR_36}与设备配对${COLOR_33}'中显示的'${COLOR_36}IP地址:端口${COLOR_33}' >>${COLOR_0}"
                echo -e -n "${COLOR_33}(格式:${COLOR_36}192.168.00.00:00000${COLOR_33})*ᐷ${COLOR_01}"
                read IP_AND_PORT
                if [ -n "$IP_AND_PORT" ] && grep ':' <<< "$IP_AND_PORT" &>>$MST_LOG
                then
                    echo -e -n "${COLOR_35}[PAIR]${COLOR_33}输入'${COLOR_36}WLAN配对码${COLOR_33}':${COLOR_01}"
                    read INPUT_PAIR_CODE
                    if [ "${#INPUT_PAIR_CODE}" != 6 ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此配对码有误 正确配对码应为${COLOR_36}六位数${COLOR_0}"
                        REBOOT_FL || return 0
                    fi
                    echo
                    echo -e "${COLOR_35}[Connecting]${COLOR_33}正在与'${COLOR_36}$IP_AND_PORT${COLOR_33}'配对...${COLOR_0}"
                    if grep -q paired <<< "$(adb pair "$IP_AND_PORT" <<< "$INPUT_PAIR_CODE" 2>&1)" &>>$MST_LOG
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}已成功与'${COLOR_36}$IP_AND_PORT${COLOR_33}'配对${COLOR_0}"
                        ONLY_IP="$(sed 's/:.*//g' <<< "$IP_AND_PORT")"
                        echo -e "${COLOR_35}[NEW]${COLOR_33}输入'${COLOR_36}无线调试${COLOR_33}'页面的'IP地址:${COLOR_36}端口${COLOR_33}'以连接 >>${COLOR_0}"
                        echo -e -n "${COLOR_33}*ᐷ ${COLOR_32}$ONLY_IP:${COLOR_01}"
                        read ONLY_PORT
                        if [ "${#ONLY_PORT}" != 5 ]
                        then
                            echo -e  "${COLOR_31}[!]${COLOR_33}输入的内容有误 此处只需要输入'${COLOR_36}5位数端口${COLOR_33}(${COLOR_31}${COLOR_RM}192.168.00.00:${COLOR_32}00000${COLOR_33})'无需输入IP${COLOR_0}"
                            REBOOT_FL || return 0
                        fi
                        NEW_IP_AND_PORT="$ONLY_IP:$ONLY_PORT"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}无法与'${COLOR_36}$IP_AND_PORT${COLOR_33}'配对${COLOR_0}"
                        echo -e "${COLOR_35}[Tip]${COLOR_33}配对开始时应保持'${COLOR_36}与设备配对${COLOR_33}'页面的开启状态 除非配对完毕后自动退出${COLOR_0}"
                        REBOOT_FL || return 0
                    fi
                else
                    echo -e "$WARIN_TIP"
                    REBOOT_FL || return 0
                fi
                ;;
            '2' | 'Android11以下')
                echo -e "${COLOR_35}[USB]${COLOR_33}要无线连接Android11以下的设备必须先进行一次有线连接 现在先将本机与目标设备使用OTG转接线连接${COLOR_0}"
                ENTER_ANY_CONTINUE
                echo
                CNT_ANY_DEVICED ADB y
                echo
                echo -e "${COLOR_35}[TCP]${COLOR_33}设备已连接 输入要设置的${COLOR_36}ADB监听端口${COLOR_33}(留空自动使用'${COLOR_36}5555${COLOR_33}'端口) >>${COLOR_0}"
                echo -e -n "${COLOR_33}(范围:${COLOR_36}1024-49151${COLOR_33})*ᐷ${COLOR_01}"
                read THE_TCP_NUMBER
                if [ -z "$THE_TCP_NUMBER" ]
                then
                    THE_TCP_NUMBER=5555
                    echo -e "${COLOR_35}[AUTO]${COLOR_33}已自动使用'${COLOR_36}5555${COLOR_33}'端口${COLOR_0}"
                elif ! [ "$THE_TCP_NUMBER" ~= ^0-9+$ ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}输入的内容'${COLOR_36}$THE_TCP_NUMBER${COLOR_33}'不是有效的数字端口 输入的数字必须在${COLOR_36}1024-49151${COLOR_33}之间${COLOR_0}"
                fi
                if [ "$THE_TCP_NUMBER" -lt 1024 ] || [ "$THE_TCP_NUMBER" -gt 49151 ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}输入的端口'${COLOR_36}$THE_TCP_NUMBER${COLOR_33}'不在规范的范围(${COLOR_36}1024-49151${COLOR_33}) 为保证安全已终止操作${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                if adb tcpip $THE_TCP_NUMBER &>>$MST_LOG
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}监听端口'${COLOR_36}$THE_TCP_NUMBER${COLOR_33}'已启动${COLOR_0}"
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}监听端口'${COLOR_36}$THE_TCP_NUMBER${COLOR_33}'启动失败 可能目标设备意外断开USB连接或系统不支持 再试一次或使用有线ADB调试${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                echo
                echo -e "${COLOR_35}[IP]${COLOR_33}正在获取目标设备IP地址...${COLOR_0}"
                if ONLY_USB_IP="$(adb -s "$SELEC_ADB_DEVICE" shell ip addr show wlan0 2>>$MST_LOG | grep 'inet ' | sed 's/.*inet //g; s|/.*||g')" && [ -n "$ONLY_USB_IP" ]
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}目标设备IP获取成功:${COLOR_36}$ONLY_USB_IP${COLOR_0}"
                    NEW_IP_AND_PORT="$ONLY_USB_IP:$THE_TCP_NUMBER"
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}无法自动获取目标设备IP地址 按照以下步骤在目标设备上手动查看 >>${COLOR_0}"
                    echo -e "${COLOR_35}[STEP]${COLOR_36}系统设置 ${COLOR_33}->${COLOR_36} WLAN(Wi-Fi)${COLOR_33} -> ${COLOR_36}已连接网络 ${COLOR_33}-> ${COLOR_36}IP地址${COLOR_0}"
                    echo
                    echo -e -n "${COLOR_35}[Input]${COLOR_33}输入IP:${COLOR_01}"
                    read ONLY_USB_IP
                    if [ "$(echo "$ONLY_USB_IP" | tr -cd '.' | wc -c)" = 3 ]
                    then
                        NEW_IP_AND_PORT="$ONLY_USB_IP:$THE_TCP_NUMBER"
                    else
                        echo -e "${COLOR_31}[!]${COLOR_33}输入的内容不符合标准的IP地址规格${COLOR_0}"
                        REBOOT_FL || return 0
                    fi
                fi
                ;;
            '')
                echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                REBOOT_FL || return 0
                ;;
            *)
                echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$THE_CONNNECT_VERSION${COLOR_33}'不是预设的选项${COLOR_0}"
                REBOOT_FL || return 0
                ;;
            esac
            if [ -z "$NEW_IP_AND_PORT" ] && ! grep ':' <<< "$NEW_IP_AND_PORT" &>>$MST_LOG
            then
                echo -e "$WARIN_TIP"
                REBOOT_FL || return 0
            fi
            CONNECT_ERROR="${COLOR_31}[ERROR]${COLOR_33}设备连接失败 检查'${COLOR_36}IP地址:端口${COLOR_33}(${COLOR_32}$NEW_IP_AND_PORT${COLOR_33})'是否有误/网络环境是否变化后重试一次或使用有线模式进行ADB调试${COLOR_0}"
            if grep connected <<< "$(adb connect $NEW_IP_AND_PORT)"
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}连接成功 正在校验...${COLOR_0}"
                if USB_DEVICES_$FASTBOOT_OR_ADB_NAME
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}设备连接成功${COLOR_0}"
                    REBOOT_FL || return 0
                else
                    echo -e "$CONNECT_ERROR"
                    REBOOT_FL || return 0
                fi
            else
                echo -e "$CONNECT_ERROR"
                REBOOT_FL || return 0
            fi
            ;;
        '4')
            MAIN_REBOOT || return 0
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
            if [ -z "$2" ]
            then
                local TIP_TEXT_2=镜像
            else
                local TIP_TEXT_2=$2
            fi
            case "$FB_DEV_BL" in
            'no')
                echo -e "${COLOR_35}[WARN]${COLOR_31}当前Fastboot设备BootLoader未解锁${COLOR_0}"
                echo -e "${COLOR_31}[!]${COLOR_33}要继续操作必须先为Fastboot设备${COLOR_36}解锁BootLoader${COLOR_33}(BL锁)${COLOR_0}"
                REBOOT_FL || return 0
                ;;
            *)
                echo -e "${COLOR_35}[WARN]${COLOR_31}刷入不兼容的$TIP_TEXT_2文件可能导致设备无法开机${COLOR_0}"
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
        echo -e "${COLOR}[FB]${COLOR_33}选择Fastboot刷机功能 >>${COLOR_0}"
        echo -e "${COLOR_35}[BOOT]${COLOR_33}›1*-${COLOR_36}刷入BOOT${COLOR_35}[REC]${COLOR_33}›2*-${COLOR_36}刷入RECOVERY${COLOR_35}[RE]${COLOR_33}›3*-${COLOR_36}重启连接设备${COLOR_0}"
        echo -e "${COLOR_35}[SLOT]${COLOR_33}›4*-${COLOR_36}刷入指定分区${COLOR_35}[ROM]${COLOR_33}›5*-${COLOR_36}刷入ROM${COLOR_35}[HOME]${COLOR_33}›6*-${COLOR_36}返回主页${COLOR_0}"
        echo -e -n "${COLOR}[-${COLOR_32}FB${COLOR}-]${COLOR_33}输入选项*ᐷ${COLOR_0}"
        CLEAR_READ_INPUT
        read FUNC_CONT
        echo -e "${COLOR_30}-------------------------------------------------${COLOR_0}"
        FLASH_IMG_TO_SLOT() {
            local FLASH_IMG_NAME=$1
            local FLASH_IMG_SLOT=$2
            local IMG_FILE_PA IMG_FILE_NAME IMG_FILE_PATH
            echo -e "${COLOR_35}[FILE]${COLOR_33}输入要刷入'${COLOR_36}$FLASH_IMG_NAME${COLOR_33}'分区的镜像文件路径 >>${COLOR_0}"
            echo -e -n "${COLOR_33}*ᐷ ${COLOR_01}"
            read IMG_FILE_PATH
            IMG_FILE_NAME=$(basename "$IMG_FILE_PATH" 2>>$MST_LOG)
            if [ -z "$IMG_FILE_PATH" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}输入不可为空${COLOR_0}"
                REBOOT_FL || return 0
            elif [ ! -f "$IMG_FILE_PATH" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}文件'${COLOR_36}$IMG_FILE_NAME${COLOR_33}'路径不存在/无法读取${COLOR_0}"
                REBOOT_FL || return 0
            fi
            echo -e "$COLOR_35[Flashing]${COLOR_33}正在将'${COLOR_36}$IMG_FILE_NAME${COLOR_33}'刷入'${COLOR_36}$FLASH_IMG_NAME${COLOR_33}'分区...${COLOR_30}"
            if fastboot -s "$SELEC_FASTBOOT_DEVICE" flash $FLASH_IMG_SLOT "$IMG_FILE_PATH"
            then
                ALL_TIP_TION="${COLOR_32}[OKAY]${COLOR_33}刷入成功 是否立即重启 >>${COLOR_0}"
                REBOOT_USB_DEVICES
            else
                echo -e "${COLOR_32}[ERROR]${COLOR_33}刷入失败 检查设备是否正确连接或镜像文件是否正确${COLOR_0}"
                REBOOT_FL || return 0
            fi
        }
        case "$FUNC_CONT" in
        '1' | 'BOOT' | '刷入BOOT')
            MISHUI_MAIN_TIP=刷入BOOT
            SEE_USB_DEVICES
            NOT_UNLOCK_ERROR
            echo -e "${COLOR_35}[SLOT]${COLOR_33}选择要刷入的分区 >>$COLOR_0"
            echo -e "${COLOR_36}›1*-Boot ›2*-Boot_a  ›3*-Boot_b ›4*-init_boot${COLOR_0}"
            echo -e "${COLOR_36}›5*-init_Boot_a ›6*-init_boot_b ›7*-自动识别${COLOR_01}"
            echo -e -n "${COLOR_35}[ST]${COLOR_33}输入选项*ᐷ${COLOR_01}"
            read YN_SLOT_AB
            case "$YN_SLOT_AB" in
            '1' | 'Boot')
                FLASH_IMG_TO_SLOT BOOT boot
                ;;
            '2' | 'a' | 'A' | 'Boot_a')
                FLASH_IMG_TO_SLOT BOOT_A boot_a
                ;;
            '3' | 'b' | 'B' | 'Boot_b')
                FLASH_IMG_TO_SLOT BOOT_B boot_b
                ;;
            '4' | 'init' | 'init_Boot')
                FLASH_IMG_TO_SLOT INIT_BOOT init_boot
                ;;
            '5' | 'init_a' | 'init_boot_a')
                FLASH_IMG_TO_SLOT INIT_BOOT_A init_boot_a
                ;;
            '6' | 'init_b' | 'init_boot_b')
                FLASH_IMG_TO_SLOT INIT_BOOT_B init_boot_b
                ;;
            '7' | '自动' | '自动识别')
                AUTO_TO_SEE_SLOT="$(fastboot -s "$SELEC_FASTBOOT_DEVICE" getvar all 2>&1)"
                if grep 'type:init_boot' <<< "$AUTO_TO_SEE_SLOT"
                then
                    FLASH_IMG_TO_SLOT INIT_BOOT init_boot
                elif grep 'type:boot' <<< "$AUTO_TO_SEE_SLOT"
                then
                    FLASH_IMG_TO_SLOT BOOT boot
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}自动识别Boot分区失败 需手动指定Boot分区${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                ;;
            *)
                if [ -z "$YN_SLOT_AB" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                echo -e "${COLOR_31}[!]${COLOR_33}不支持的选项:${COLOR_36}$YN_SLOT_AB${COLOR_0}"
                REBOOT_FL || return 0
                ;;
            esac
            ;;
        '2' | 'REC' | '刷入RECOVERY')
            MISHUI_MAIN_TIP=刷入RECOVERY
            SEE_USB_DEVICES
            NOT_UNLOCK_ERROR
            FLASH_IMG_TO_SLOT RECOVERY recovery
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
                REBOOT_FL || return 0
            else
                echo -e "${COLOR_35}[Y/N]${COLOR_33}是否确定指定分区为:${COLOR_36}$FLASH_IMG_SLOT${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›确定分区/2›返回主页]*ᐷ${COLOR_01}"
                read YN_INPUT_SLOT
                case "$YN_INPUT_SLOT" in
                '1' | 'y' | 'Y')
                    FLASH_IMG_NAME="${FLASH_IMG_NAME^^}"
                    echo -e "${COLOR_32}[CFM]${COLOR_33}已确定指定分区为:${COLOR_36}$FLASH_IMG_SLOT${COLOR_0}"
                    FLASH_IMG_TO_SLOT "$FLASH_IMG_NAME" "$FLASH_IMG_SLOT"
                    ;;
                *)
                    MAIN_REBOOT || return 0
                    ;;
                esac
            fi
            ;;
        '5' | '刷入ROM' | 'ROM')
            MISHUI_MAIN_TIP=刷入ROM
            SEE_USB_DEVICES
            NOT_UNLOCK_ERROR "刷机包不对" "Rom"
            CHECK_DEVICE_FLASH_OK() {
                echo -e -n "${COLOR_35}[+/-]${COLOR_33}当前电量:${COLOR_0}"
                PEAGE_TEXT="$(termux-battery-status 2>>$MST_LOG)"
                NOW_PEAGE="$(echo "$PEAGE_TEXT" | grep 'percentage' | sed 's/.*: //g; s/,//g' 2>>$MST_LOG)"
                ALL_PEAGE="$(echo "$PEAGE_TEXT" | grep 'scale' | sed 's/.*: //g; s/,//g' 2>>$MST_LOG)"
                NUMBER_PEAGR="${COLOR_36}$NOW_PEAGE%${COLOR_33}/${COLOR_36}$ALL_PEAGE%${COLOR_33}-"
                if [ -z "$PEAGE_TEXT" ]
                then
                    echo -e "${COLOR_31}无法读取${COLOR_0}"
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}MST无法读取本机电量执行判断 若本机电量高于${COLOR_36}45%${COLOR_33}则可以继续操作 >>${COLOR_0}"
                    echo -e "${COLOR_36}[+][1›高于45%/2›低于45%]*ᐷ${COLOR_01}"
                    read PEAGE_YN_FF
                    case "$PEAGE_YN_FF" in
                    '2')
                        echo
                        echo -e "${COLOR_31}[WARN]${COLOR_33}设备电量过低可能导致刷入过程中意外断电 需将当前设备充至${COLOR_36}80%${COLOR_33}以上才可继续操作${COLOR_0}"
                        REBOOT_FL || return 0
                        ;;
                     esac
                elif [ "$NOW_PEAGE" -ge '80' ]
                then
                    echo -e "$NUMBER_PEAGR${COLOR_32}电量充足${COLOR_0}"
                elif [ "$NOW_PEAGE" -lt '40' ]
                then
                    echo -e "$NUMBER_PEAGR${COLOR_31}严重不足${COLOR_0}"
                    echo -e "${COLOR_35}[WARN]${COLOR_31}本机当前电量严重不足 必须保证本机电量高于${COLOR_36}40%${COLOR_31}才能顺利完成刷入${COLOR_0}"
                    REBOOT_FL || return 0
                else
                    echo -e "$NUMBER_PEAGR${COLOR_34}电量较足${COLOR_0}"
                    echo -e "${COLOR_35}[INFO]${COLOR_33}本机当前电量较为充足但仍然存在断电风险 是否继续 >>${COLOR_0}"
                    echo -e -n "${COLOR_36}[+][1›继续刷入/2›取消并返回主页]*ᐷ${COLOR_01}"
                    read PEABG_CONTINUE_YN
                    case "$PEABG_CONTINUE_YN" in
                    '1' | 'y' | 'Y')
                        echo -e "${COLOR_35}[CONTINUE]${COLOR_33}已确认继续操作${COLOR_0}"
                        ;;
                    *)
                        MAIN_REBOOT || return 0
                        ;;
                    esac
                fi
                echo
                echo -e "${COLOR_35}[WARN]${COLOR_33}刷入之前必须确保所选刷机包与目标设备相符 检查刷机包/自带脚本/电量等是否准确无误 ${COLOR_31}准备不充分的刷机操作将导致不开机甚至黑砖${COLOR_33} 刷入过程中将设备(${COLOR_36}本机与目标设备${COLOR_33})与连接的数据线平放并避免触碰以保证刷入过程中不会意外中断${COLOR_0}"
                echo -e -n "${COLOR_35}[INPUT]${COLOR_33}输入' ${COLOR_36}已确认并继续${COLOR_33} '以继续:${COLOR_01}"
                local USER_INPUT_CONTINUE_NUMBER=1
                CLEAR_READ_INPUT
                while true
                do
                    if [ "$USER_INPUT_CONTINUE_NUMBER" -ge 3 ]
                    then
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}超过三次无效确认已终止操作${COLOR_0}"
                        REBOOT_FL || return 0
                        break
                    else
                        USER_INPUT_CONTINUE_NUMBER=$((USER_INPUT_CONTINUE_NUMBER + 1))
                    fi
                    local CONTINUE_FLASH_ROM
                    read CONTINUE_FLASH_ROM
                    if [ "$CONTINUE_FLASH_ROM" = "已确认并继续" ]
                    then
                        echo -e -n " ${COLOR_35}[START]${COLOR_33}3秒后开始刷入${COLOR_0}\r"
                        sleep 3
                        break
                    else
                        echo -e -n "${COLOR_31}[!]${COLOR_33}无效确认 输入' ${COLOR_36}已确认并继续 ${COLOR_33}'以继续:${COLOR_01}"
                        continue
                    fi
                done
                echo -e "\033[K"
            }
            FLASH_ALL_OKAY() {
                OKAY_PEAGE=$(termux-battery-status | grep 'percentage' | sed 's/.*: //g; s/,//g')
                echo -e "${COLOR_35}[COMP]${COLOR_33}消耗电量:${COLOR_36}$(awk "BEGIN {printf \"%.2f\", $NOW_PEAGE - $OKAY_PEAGE}")%${COLOR_33}/耗时:${COLOR_36}$(awk "BEGIN {printf \"%.2f\", $FLASH_END - $FLASH_START}")s${COLOR_0}"
                ALL_TIP_TION="${COLOR_35}[ROM]${COLOR_33}Rom已完成刷入 是否立即重启设备 >>${COLOR_0}"
                REBOOT_USB_DEVICES
            }
            echo -e "${COLOR_35}[PATH]${COLOR_33}输入${COLOR_36}'线刷包${COLOR_33}'或'${COLOR_36}解压后文件夹${COLOR_33}'的完整路径 >>${COLOR_0}"
            echo -e -n "${COLOR_33}*ᐷ ${COLOR_01}"
            read ZIP_DIR_PATH
            if [ -f "$ZIP_DIR_PATH" ]
            then
                echo -e "${COLOR_35}[ZIP]${COLOR_33}该路径指向为:${COLOR_36}压缩包${COLOR_0}"
                THE_FILE_FLASH_NAME="$(basename "$ZIP_DIR_PATH")"
                THE_PATH_FLASH_NAME="$(dirname "$ZIP_DIR_PATH")/线刷包-MST"
                INSTALL_THE_MUST_CMD 'pkg install unzip -y' 'unzip' 'unzip'
                
                if unzip -t "$ZIP_DIR_PATH" android-info.txt &>>$MST_LOG
                then
                    echo -e "${COLOR_35}[Tip]${COLOR_33}该压缩包内置'${COLOR_36}android-info.txt${COLOR_33}'文件 可直接刷入${COLOR_0}"
                    echo -e "${COLOR_35}[INFO]${COLOR_33}该压缩包支持使用'${COLOR_33}fastboot update${COLOR_33}'命令直接刷入而无需解压 但是以该方式刷入的刷机包可能不完整 需慎重考虑${COLOR_0}"
                    echo
                    echo -e "${COLOR_35}[Update]${COLOR_33}是否以'${COLOR_33}fastboot update${COLOR_33}'命令刷入 >>${COLOR_0}"
                    echo -e -n "${COLOR_36}[+][1›使用Update/2›使用刷机脚本]*ᐷ${COLOR_0}"
                    read YN_UPDATE_FLASH
                    case "$YN_UPDATE_FLASH" in
                    1 | y | Y)
                        CHECK_DEVICE_FLASH_OK
                        echo -e "${COLOR_35}[Flashing]${COLOR_33}正在以'${COLOR_33}fastboot update${COLOR_33}'命令刷入'${COLOR_36}$THE_FILE_FLASH_NAME${COLOR_33}' >>${COLOR_0}"
                        if fastboot update "$THE_FILE_FLASH_NAME" && FLASH_END=$(date +%s.%N)
                        then
                            echo -e "${COLOR_36}[Done]${COLOR_33}已完成刷入${COLOR_0}"
                            FLASH_ALL_OKAY
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}刷入失败 检查刷机包是否与设备相符或刷入过程中数据线是否意外断开${COLOR_0}"
                        fi
                        REBOOT_FL || return 0
                        ;;
                    esac
                fi
                if ! mkdir -p "$THE_PATH_FLASH_NAME" &>>$MST_LOG
                then
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}无法创建存放解压后镜像文件的文件夹 MST工具箱无法自动解压该压缩包:${COLOR_36}$THE_FILE_FLASH_NAME${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_33}手动解压后输入'${COLOR_36}解压后文件夹${COLOR_33}'路径以继续${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                case "$THE_FILE_EXT_NAME" in
                'zip')
                    INSTALL_THE_MUST_CMD 'pkg install unzip -y' 'unzip' 'unzip'
                    UNZIP_CMD() {
                        if unzip "$ZIP_DIR_PATH" -d "$THE_PATH_FLASH_NAME" && TMP_UNZIP_DIR=$(find "$THE_PATH_FLASH_NAME" -mindepth 1 -maxdepth 1 -type d -print -quit) && mv "$TMP_UNZIP_DIR"/* "$THE_PATH_FLASH_NAME/" 2>$MST_LOG
                        then
                            return 0
                        else
                            return 1
                        fi
                    }
                    ;;
                'tgz' | 'tar' | 'gz' | 'bz2' | 'xz' | 'zst' | 'lzma' | 'Z')
                    INSTALL_THE_MUST_CMD 'pkg install tar -y' 'tar' 'tar'
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
                    echo -e "${COLOR_35}[Tip]${COLOR_33}目前仅支持对'${COLOR_36}.zip${COLOR_33}'与'${COLOR_36}.tgz${COLOR_33}'压缩文件自动解压 其他格式需手动解压${COLOR_0}"
                    REBOOT_FL || return 0
                    ;;
                esac
                echo -e "${COLOR_35}[Uziping]${COLOR_33}正在解压'${COLOR_36}$THE_FILE_FLASH_NAME${COLOR_33}'文件...${COLOR_30}"
                if UNZIP_CMD
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}已将线刷包解压至文件夹:${COLOR_36}$THE_PATH_FLASH_NAME${COLOR_0}"
                else
                     echo -e "${COLOR_31}[ERROR]${COLOR_33}线刷包解压失败 尝试手动解压并输入${COLOR_36}文件夹${COLOR_33}路径${COLOR_0}"
                    REBOOT_FL || return 0
                fi
            elif [ -d "$ZIP_DIR_PATH" ]
            then
                echo -e "${COLOR_35}[DIR]${COLOR_33}该路径指向为:${COLOR_36}文件夹${COLOR_30}"
                THE_PATH_FLASH_NAME="${ZIP_DIR_PATH%%/}"
            else
                echo -e "${COLOR_31}[ERROR]${COLOR_33}路径不存在或无法访问${COLOR_0}"
                REBOOT_FL || return 0
            fi
            SH_FILE_NUM=1
            echo
            echo -e "${COLOR_35}[FIND]${COLOR_33}正在查找刷机包文件夹中的'${COLOR_36}.sh${COLOR_33}'脚本...${COLOR_0}"
            ALL_SH_FILE=''
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
                echo -e "${COLOR_35}[Tip]${COLOR_33}检查该文件夹(${COLOR_36}$THE_PATH_FLASH_NAME${COLOR_33})是否指向刷机包解压后的文件夹${COLOR_0}"
                REBOOT_FL || return 0
            fi
            echo -e -n "${COLOR_35}[SH]${COLOR_33}输入需要使用的脚本选项*ᐷ${COLOR_01}"
            read USR_SH_NUMBER
            case "$USR_SH_NUMBER" in
            [1-9])
                USR_SH_FALSH="$(sed -n ${USR_SH_NUMBER}p <<< "$ALL_SH_FILE")"
                if [ -z "$USR_SH_FALSH" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$USR_SH_NUMBER${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL || return 0
                else
                    echo -e "${COLOR_35}[USR]${COLOR_33}是否使用'${COLOR_36}$(basename "$USR_SH_FALSH")${COLOR_33}'脚本进行刷机 >>${COLOR_0}"
                    echo -e -n "${COLOR_36}[+][1›确认使用/2›取消并返回主页]*ᐷ${COLOR_01}"
                    read YN_CONTINUE_FLASH
                    case "$YN_CONTINUE_FLASH" in
                    '2' | 'n' | 'N')
                        MAIN_REBOOT || return 0
                        ;;
                    esac
                fi
                ;;
            *)
                if [ -z "$USR_SH_NUMBER" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                    MAIN_REBOOT || return 0
                fi
                echo -e "${COLOR_34}[INFO]${COLOR_33}'${COLOR_36}$USR_SH_NUMBERL_YN${COLOR_33}'非菜单中的选项${COLOR_0}"
                REBOOT_FL || return 0
                ;;
            esac
            echo
            CHECK_DEVICE_FLASH_OK
            echo -e "${COLOR_35}[Flashing]${COLOR_33}正在使用'${COLOR_36}$(basename "$USR_SH_FALSH")${COLOR_33}'脚本刷入ROM...${COLOR_0}"
            FLASH_START=$(date +%s.%N)
            fastboot() {
                if [[ "$1" == reboot* ]]
                then
                    echo -e "${COLOR_34}[INT]${COLOR_33}已拦截刷机脚本的重启命令:${COLOR_36}fastboot $@${COLOR_0}"
                else
                    command fastboot "$@"
                fi
            }
            export -f fastboot
            if bash "$USR_SH_FALSH" && FLASH_END=$(date +%s.%N) && unset -f fastboot &>>$MST_LOG
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}刷机脚本'${COLOR_36}$(basename "$USR_SH_FALSH")${COLOR_33}'运行结束${COLOR_0}"
                
            else
                unset -f fastboot
                echo -e "${COLOR_31}[ERROR]${COLOR_33}刷入失败 检查刷机包是否与设备相符或刷入过程中数据线是否意外断开${COLOR_0}"
            fi
            REBOOT_FL || return 0
            ;;
        '6' | 'HOME' | '返回主页')
            MAIN_REBOOT || return 0
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
        echo -e "${COLOR}[ADB]${COLOR_33}选择ADB调试功能 >>${COLOR_0}"
        echo -e "${COLOR_35}[ACT]${COLOR_33}›1*-${COLOR_36}激活ADB应用${COLOR_35}[APP]${COLOR_33}›2*-${COLOR_36}应用管理${COLOR_35}[CMD]${COLOR_33}›3*-${COLOR_36}自定义ADBShell命令${COLOR_0}"
        echo -e "${COLOR_35}[SET]${COLOR_33}›4*-${COLOR_36}高级系统设置${COLOR_35}[RE]${COLOR_33}›5*-${COLOR_36}重启连接设备${COLOR_35}[HOME]${COLOR_33}›6*-${COLOR_36}返回主页${COLOR_0}"
        echo -e -n "${COLOR}[-${COLOR_32}ADB${COLOR}-]${COLOR_33}输入选项*ᐷ${COLOR_0}"
        CLEAR_READ_INPUT
        read FUNC_CONT
        echo -e "${COLOR_30}-------------------------------------------------${COLOR_0}"
        case "$FUNC_CONT" in
        '1' | 'ACT' | '激活ADB应用')
            MISHUI_MAIN_TIP=激活ADB应用
            SEE_USB_DEVICES
            ACT_ADB_APP() {
                local ACT_APP_NAME="$1"
                local ACT_APP_PATH="$2"
                local START_APP_CMD="$3"
                if ! adb -s "$SELEC_ADB_DEVICE" shell ls $STORAGE/Android/data/$(sed 's|/.*||g' <<< "$START_APP_CMD") &>>$MST_LOG
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}目标设备暂未安装应用'${COLOR_36}$ACT_APP_NAME${COLOR_33}'无法激活${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_33}前往应用官网或可信渠道下载后安装至目标设备 也可以将APK文件下载至本机后使用'${COLOR_36}[ADB]›3*-ADB调试工具${COLOR_33} -> ${COLOR_36}[APP]›2*-应用管理 ${COLOR_33}-> ${COLOR_36}安装APK/卸载选定应用 ${COLOR_33}-> ${COLOR_36}安装APK${COLOR_33}'功能将APK安装至目标设备${COLOR_0}"
                    echo
                fi
                echo -e "${COLOR_35}[P-ACT]${COLOR_33}正在激活'${COLOR_36}$ACT_APP_NAME${COLOR_33}'...${COLOR_30}"
                if adb -s "$SELEC_ADB_DEVICE" shell am start -n $START_APP_CMD 2>>$MST_LOG; adb -s "$SELEC_ADB_DEVICE" shell "$ACT_APP_PATH"
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}激活'${COLOR_36}$ACT_APP_NAME${COLOR_33}'命令执行完毕${COLOR_0}"
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}激活'${COLOR_36}$ACT_APP_NAME${COLOR_33}'命令执行失败${COLOR_0}"
                    echo -e "${COLOR_35}[CMD]${COLOR_33}手动激活命令: ${COLOR_36}adb -s "$SELEC_ADB_DEVICE" shell sh $ACT_APP_PATH${COLOR_0}"
                fi
            }
            ALL_TIP_TION="${COLOR_35}[APP]${COLOR_33}已支持ADB激活的应用 >>${COLOR_0}"
            ALL_OPTION=("1*-Shizuku-ADB" "2*-Scene6-ADB" "3*-黑阈-ADB" "4*-全部激活-3个" "5*-返回主页")
            NOW_LINE
            SHOW_FUNC_MENU
            case "$FUNC_CONT" in
            '1')
                ACT_ADB_APP 'Shizuku-ADB' "$(adb -s "$SELEC_ADB_DEVICE" shell pm path moe.shizuku.privileged.api | sed 's/package://g; s|base.apk|lib/arm64/libshizuku.so|g')" 'moe.shizuku.privileged.api/moe.shizuku.manager.MainActivity'
                ;;
            '2')
                ACT_ADB_APP 'Scene6-ADB' "sh $STORAGE/Android/data/com.omarea.vtools/up.sh" 'com.omarea.vtools/com.omarea.vtools.activities.ActivityStartSplash'
                ;;
            '3')
                ACT_ADB_APP '黑阈-ADB' "$(adb -s "$SELEC_ADB_DEVICE" shell pm path me.piebridge.brevent | sed 's/package://g; s|base.apk|lib/arm64/libbrevent.so|g')" 'me.piebridge.brevent/me.piebridge.brevent.ui.BreventActivity'
                ;;
            '4')
                ACT_ADB_APP 'Shizuku-ADB' "$(adb -s "$SELEC_ADB_DEVICE" shell pm path moe.shizuku.privileged.api | sed 's/package://g; s|base.apk|lib/arm64/libshizuku.so|g')" 'moe.shizuku.privileged.api/moe.shizuku.manager.MainActivity'
                ACT_ADB_APP 'Scene6-ADB' "sh $STORAGE/Android/data/com.omarea.vtools/up.sh" 'com.omarea.vtools/com.omarea.vtools.activities.ActivityStartSplash'
                ACT_ADB_APP '黑阈-ADB' "$(adb -s "$SELEC_ADB_DEVICE" shell pm path me.piebridge.brevent | sed 's/package://g; s|base.apk|lib/arm64/libbrevent.so|g')" 'me.piebridge.brevent/me.piebridge.brevent.ui.BreventActivity'
                ;;
            '5')
                MAIN_REBOOT || return 0
                ;;
            *)
                ERROR_CONT
            ;;
            esac
            REBOOT_FL || return 0
            ;;
        '2' | 'APP' | '应用管理')
            MISHUI_MAIN_TIP=应用管理
            MISHUI_MAIN
            echo
            SEARCH_THE_NEED_APPS() {
                local INPUT_PKGE_NUMBER ALL_SEARCH
                local INPUT_PKGE_NAME ALL_LIST_PKGE
                local SEARCH_LINR OKAY_SEARCH
                local START_YN_APP ONE_SEARCH
                echo -e "${COLOR_35}[PKGE]${COLOR_33}输入'${COLOR_36}包名${COLOR_33}'或'${COLOR_36}包名关键词${COLOR_33}'以搜索应用(多选以'${COLOR_36}-${COLOR_33}'符号分隔) >>${COLOR_0}"
                echo -e -n "${COLOR_33}*ᐷ ${COLOR_01}"
                read INPUT_PKGE_NAME
                if [ -z "$INPUT_PKGE_NAME" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                    REBOOT_FL || return 0
                else
                    IFS='-' read -ra INPUT_PKGE_NAME <<< "$INPUT_PKGE_NAME"
                fi
                echo
                echo -e "${COLOR_35}[SRCH]${COLOR_33}正在搜索包含'${COLOR_36}${INPUT_PKGE_NAME[*]}${COLOR_33}'的包名...${COLOR_0}"
                ALL_LIST_PKGE="$(adb -s "$SELEC_ADB_DEVICE" shell pm list packages --user current 2>>$MST_LOG)"
                if [ -z "$ALL_LIST_PKGE" ]
                then
                    ALL_LIST_PKGE="$(adb -s "$SELEC_ADB_DEVICE" shell pm list packages 2>>$MST_LOG)"
                fi
                PKGE_NUMBER=1
                ALL_SEARCH=""
                for ONE_SEARCH in "${INPUT_PKGE_NAME[@]}"
                do
                    OKAY_SEARCH=$(echo "$ALL_LIST_PKGE" | sed 's/.*age://g' | grep -- "$ONE_SEARCH")
                    while IFS= read -r SEARCH_LINR
                    do
                        if grep -x "$SEARCH_LINR" <<< "$ALL_SEARCH" &>>$MST_LOG
                        then
                            continue
                        elif [ -n "$SEARCH_LINR" ]
                        then
                            echo -e "${COLOR_33}›$PKGE_NUMBER*-${COLOR_36}$SEARCH_LINR${COLOR_0}"
                            ALL_SEARCH+=$SEARCH_LINR$'\n'
                            PKGE_NUMBER=$((PKGE_NUMBER + 1))
                        fi
                    done <<< "$OKAY_SEARCH"
                done
                if [ -z "$ALL_SEARCH" ]
                then
                    echo -e "${COLOR_31}[!]${COLOR_33}没有发现包含'${COLOR_36}${INPUT_PKGE_NAME[*]}${COLOR_33}'的包名${COLOR_0}"
                    REBOOT_FL || return 0
                else
                    echo -e -n "${COLOR_35}[NUM]${COLOR_33}输入选定序号(多选以'${COLOR_36}-${COLOR_33}'符号分隔)*ᐷ${COLOR_01}"
                    read INPUT_PKGE_NUMBER
                fi
                if [ -z "$INPUT_PKGE_NUMBER" ]
                then
                    echo -e "${COLOR_35}[!]${COLOR_33}此处输入不可为空${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                INPUT_PKGE_NUMBER="$(sed 's/-/p; /g' <<< "${INPUT_PKGE_NUMBER%%-}" 2>>$MST_LOG)"
                if USR_OKAY_PKGE="$(sed -n "${INPUT_PKGE_NUMBER}p;" <<< "$ALL_SEARCH" | awk '!a[$0]++')" && [ -n "$USR_OKAY_PKGE" ]
                then
                    echo -e "${COLOR_35}[USR]${COLOR_33}已选定应用列表 >>${COLOR_0}"
                    echo -e "${COLOR_36}$USR_OKAY_PKGE${COLOR_0}"
                else
                    echo -e "${COLOR_31}[!]${COLOR_33}无法解析输入的内容 要进行多选只能使用'${COLOR_36}-${COLOR_33}'符号分隔${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                echo
                echo -e "${COLOR_35}[>>]${COLOR_33}是否继续操作:${COLOR_36}$MISHUI_MAIN_TIP${COLOR_33} >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›继续操作/2›取消并返回主页]*ᐷ${COLOR_0}"
                read START_YN_APP
                case "$START_YN_APP" in
                '1' | 'y' | 'Y')
                    echo -e "${COLOR_30}"
                    ;;
                *)
                    MAIN_REBOOT || return 0
                    ;;
                esac
            }
            ALL_TIP_TION="${COLOR_35}[APP]${COLOR_33}选择对目标设备应用的管理功能 >>${COLOR_0}"
            ALL_OPTION=("1*-冻结/解冻选定应用" "2*-安装APK/卸载选定应用" "3*-打开/关闭选定应用" "4*-提取选定应用Apk至本机" "5*-清理选定应用所有数据" "6*-返回主页")
            NOW_LINE
            SHOW_FUNC_MENU
            case "$FUNC_CONT" in
            '1')
                ICE_THE_USR_APPS() {
                local THE_ICE_USR="$1"
                local THE_ICE_CMD="$2"
                local ICE_THE_APP
                while IFS= read -r ICE_THE_APP
                do
                    if echo -e -n "$COLOR_30" && adb -s "$SELEC_ADB_DEVICE" shell pm disable-user "$ICE_THE_APP"
                    then
                       echo -e "${COLOR_32}[OKAY]${COLOR_33}应用'${COLOR_36}$ICE_THE_APP${COLOR_33}'$THE_ICE_USR成功${COLOR_0}"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}应用'${COLOR_36}$ICE_THE_APP${COLOR_33}'$THE_ICE_USR失败${COLOR_0}"
                        echo -e "${COLOR_35}[Tip]${COLOR_33}检查设备是否正确连接或手动执行命令 >>${COLOR_0}"
                        echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb -s $SELEC_ADB_DEVICE shell pm disable-user $ICE_THE_APP${COLOR_0}"
                    fi
                done <<< "$USR_OKAY_PKGE"
                REBOOT_FL || return 0
            }
                echo -e "${COLOR_35}[ICE]${COLOR_33}选择需要对选定应用进行的冻结/解冻操作 >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›冻结选定应用/2›解冻选定应用]*ᐷ${COLOR_0}"
                read YN_ICE_USR
                case "$YN_ICE_USR" in
                '1' | '冻结' | '冻结选定应用')
                    MISHUI_MAIN_TIP=冻结选定应用
                    SEE_USB_DEVICES
                    SEARCH_THE_NEED_APPS
                    ICE_THE_USR_APPS '冻结' 'disable-user'
                    ;;
                '2' | '解冻' | '解冻选定应用')
                    MISHUI_MAIN_TIP=解冻选定应用
                    SEE_USB_DEVICES
                    SEARCH_THE_NEED_APPS
                    ICE_THE_USR_APPS '解冻' 'enable'
                    ;;
                *)
                    if [ -z "$YN_ICE_USR" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                        sleep 0.3
                        MAIN_REBOOT || return 0
                    fi
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$YN_ICE_USR${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL || return 0
                    ;;
                esac
                REBOOT_FL || return 0
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
                    echo -e -n "${COLOR_33}*ᐷ ${COLOR_01}"
                    read APK_INSTALL_PATH
                    INSTALL_APK_NAMR="$(basename "$APK_INSTALL_PATH")"
                    if [ -z "$APK_INSTALL_PATH" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处输入不可为空${COLOR_0}"
                        REBOOT_FL || return 0
                    elif [ ! -f "$APK_INSTALL_PATH" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}文件'${COLOR_36}$INSTALL_APK_NAMR${COLOR_33}'不存在${COLOR_0}"
                        REBOOT_FL || return 0
                    fi
                    echo -e "${COLOR_35}[Installing]${COLOR_33}正在安装'${COLOR_36}$INSTALL_APK_NAMR${COLOR_33}'...${COLOR_30}"
                    if adb -s "$SELEC_ADB_DEVICE" install "$APK_INSTALL_PATH" </dev/null
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}APK安装成功${COLOR_0}"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}APK安装失败${COLOR_0}"
                        echo -e "${COLOR_35}[Tip]${COLOR_33}检查设备是否正确连接或手动执行命令 >>${COLOR_0}"
                        echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb -s "$SELEC_ADB_DEVICE" install $APK_INSTALL_PATH${COLOR_0}"
                    fi
                    ;;
                '2' | '卸载' | '卸载选定应用')
                    MISHUI_MAIN_TIP=卸载选定应用
                    SEE_USB_DEVICES
                    SEARCH_THE_NEED_APPS
                    while IFS= read -r UN_THE_APP
                    do
                        echo -e "${COLOR_35}[Uninstalling]${COLOR_33}正在卸载'${COLOR_36}$UN_THE_APP${COLOR_33}'...${COLOR_30}"
                        if adb -s "$SELEC_ADB_DEVICE" shell pm enable "$UN_THE_APP" </dev/null && adb -s "$SELEC_ADB_DEVICE" uninstall "$UN_THE_APP" </dev/null
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}应用'${COLOR_36}$UN_THE_APP${COLOR_33}'卸载成功${COLOR_0}"
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}应用'${COLOR_36}$UN_THE_APP${COLOR_33}'卸载失败${COLOR_0}"
                            echo -e "${COLOR_35}[Tip]${COLOR_33}检查设备是否正确连接或手动执行命令 >>${COLOR_0}"
                            echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb -s $SELEC_ADB_DEVICE uninstall -k $ICE_THE_APP${COLOR_0}"
                        fi
                    done <<< "$USR_OKAY_PKGE"
                    REBOOT_FL || return 0
                    ;;
                *)
                    if [ -z "$UNINSTALL_YN" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                        sleep 0.3
                        MAIN_REBOOT || return 0
                    fi
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$UNINSTALL_YN${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL || return 0
                    ;;
                esac
                REBOOT_FL || return 0
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
                        if APP_S_ACTIVITY=$(adb -s "$SELEC_ADB_DEVICE" shell cmd package resolve-activity --brief "$START_THE_APP" </dev/null | tail -n 1) && [ -n "$APP_S_ACTIVITY" ]
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}Activity获取成功:${COLOR_36}$APP_S_ACTIVITY${COLOR_0}"
                            echo -e "${COLOR_35}[Starting]${COLOR_33}正在打开'${COLOR_36}$START_THE_APP${COLOR_33}'...$COLOR_30"
                            if adb -s "$SELEC_ADB_DEVICE" shell am start -n "$APP_S_ACTIVITY" </dev/null
                            then
                                echo -e "${COLOR_32}[OKAY]${COLOR_33}应用打开成功${COLOR_0}"
                            else
                                echo -e "${COLOR_31}[ERROR]${COLOR_33}应用打开失败${COLOR_0}"
                                echo -e "${COLOR_35}[Tip]${COLOR_33}尝试在被连接设备上手动抓取Activity并手动执行命令 >>${COLOR_0}"
                                echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb -s $SELEC_ADB_DEVICE shell am start -n $START_THE_APP/<Activity>${COLOR_0}"
                            fi
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}应用'${COLOR_36}$ICE_THE_APP${COLOR_33}'Activity获取失败${COLOR_0}"
                        fi
                    done <<< "$USR_OKAY_PKGE"
                    REBOOT_FL || return 0
                    ;;
                '2' | '关闭选定应用' | '关闭')
                    MISHUI_MAIN_TIP=关闭选定应用
                    SEE_USB_DEVICES
                    SEARCH_THE_NEED_APPS
                    while IFS= read -r KILL_THE_APP
                    do
                        echo -e "${COLOR_35}[KILL]${COLOR_33}正在杀死'${COLOR_36}$KILL_THE_APP${COLOR_33}'的全部进程...${COLOR_30}"
                        if adb -s "$SELEC_ADB_DEVICE" shell am force-stop "$KILL_THE_APP" </dev/null
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}已成功杀死'${COLOR_36}$KILL_THE_APP${COLOR_33}'的全部进程${COLOR_0}"
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}进程关闭失败 检查是否正确与目标设备连接${COLOR_0}"
                        fi
                    done <<< "$USR_OKAY_PKGE"
                    REBOOT_FL || return 0
                    ;;
                *)
                    if [ -z "$KILL_YN_START" ]
                    then
                        echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                        sleep 0.3
                        MAIN_REBOOT || return 0
                    fi
                    echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$KILL_YN_START${COLOR_33}'非菜单中的选项${COLOR_0}"
                    REBOOT_FL || return 0
                    ;;
                esac
                ;;
            '4')
                MISHUI_MAIN_TIP=提取应用Apk至本机
                SEE_USB_DEVICES
                SEARCH_THE_NEED_APPS
                echo -e "${COLOR_35}[DL]${COLOR_33}输入存放Apk文件的文件夹路径(留空自动存储至'${COLOR_36}Download${COLOR_33}'文件夹) >>${COLOR_0}"
                echo -e -n "${COLOR_33}*ᐷ ${COLOR_01}"
                read THE_DOWNLOAD_PATH
                if [ -n "$THE_DOWNLOAD_PATH" ] && [ -d "$THE_DOWNLOAD_PATH" ]
                then
                    THE_DOWNLOAD_PATH="${THE_DOWNLOAD_PATH%%/}"
                elif [ -z  "$THE_DOWNLOAD_PATH" ]
                then
                    THE_DOWNLOAD_PATH=$DOWNLOAD_PATH
                else
                    echo -e "${COLOR_31}[!]${COLOR_33}无法在本机找到路径:${COLOR_36}$THE_DOWNLOAD_PATH${COLOR_0}"
                    echo -e "${COLOR_35}[Tip]${COLOR_33}检查路径是否正确或是否已授予Termux访问存储目录权限后再试 若此文件夹位于高权限文件夹那么需使用Root权限启动MST${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                DOWNLOAD_APK_FILE() {
                    local ONE_PULL_APK_PATH="$1"
                    local THE_DOWNLOAD_APK_PATH="$2"
                    if echo -e -n "$COLOR_30" && adb -s "$SELEC_ADB_DEVICE" pull "$ONE_PULL_APK_PATH" "$THE_DOWNLOAD_APK_PATH" </dev/null
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}已成功将'${COLOR_36}$PULL_THE_APK${COLOR_33}'应用的Apk文件提取至本机路径:${COLOR_36}$THE_DOWNLOAD_APK_PATH${COLOR_0}"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}APK文件提取失败 尝试手动复制APK文件${COLOR_0}"
                        echo -e "${COLOR_35}[PATH]${COLOR_33}APK文件路径:${COLOR_36}$THE_APK_PULL_PATH${COLOR_0}"
                    fi
                }
                while IFS= read PULL_THE_APK
                do
                    echo
                    echo -e "${COLOR_35}[DATA]${COLOR_33}正在获取'${COLOR_36}$PULL_THE_APK${COLOR_33}'的APK文件路径...${COLOR_0}"
                    THE_APK_PULL_PATH="$(adb -s "$SELEC_ADB_DEVICE" shell pm path "$PULL_THE_APK" </dev/null 2>>$MST_LOG | sed 's/package://')"
                    ALL_APK_NUMBER="$(wc -l <<< "$THE_APK_PULL_PATH")"
                    if  [ -n "$THE_APK_PULL_PATH" ] && [ "$ALL_APK_NUMBER" = 1 ]
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}路径已获取 正在提取apk...${COLOR_30}"
                        DOWNLOAD_APK_FILE "$THE_APK_PULL_PATH" "$THE_DOWNLOAD_PATH/$PULL_THE_APK.apk"
                    elif [ -n "$THE_APK_PULL_PATH" ] && [ "$ALL_APK_NUMBER" -ge 2 ]
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}应用'${COLOR_36}$PULL_THE_APK${COLOR_33}'拥有${COLOR_36}$ALL_APK_NUMBER${COLOR_33}个Apk文件 正在将所有Apk提取至'${COLOR_36}$THE_DOWNLOAD_PATH/$PULL_THE_APK${COLOR_33}'...${COLOR_30}"
                        if ! mkdir -p "$THE_DOWNLOAD_PATH/$PULL_THE_APK" &>>$MST_LOG
                        then
                            echo
                            echo -e "${COLOR_31}[ERROR]${COLOR_36}自动创建'${COLOR_36}$THE_DOWNLOAD_PATH/$PULL_THE_APK${COLOR_33}'文件夹失败 无法提取'${COLOR_36}$PULL_THE_APK${COLOR_33}'的所有Apk文件${COLOR_0}"
                            continue
                        fi
                        while IFS= read ONE_PULL_APK
                        do
                            DOWNLOAD_APK_FILE "$ONE_PULL_APK" "$THE_DOWNLOAD_PATH/$PULL_THE_APK/$(basename "$ONE_PULL_APK")"
                        done <<< "$THE_APK_PULL_PATH"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}路径获取失败 尝试手动定位并复制APK文件${COLOR_0}"
                    fi
                done <<< "$USR_OKAY_PKGE"
                REBOOT_FL || return 0
                ;;
            '5')
                MISHUI_MAIN_TIP=清理指定应用所有数据
                SEE_USB_DEVICES
                SEARCH_THE_NEED_APPS
                local ALL_CLEAN_APP=0
                local OKAY_CLEAN_APP=0
                local ERROR_CLEAN_APP=0
                while IFS= read ONE_CLEAN_APP
                do
                    echo -e "${COLOR_35}[Cleaning]${COLOR_33}正在清理应用'${COLOR_36}$ONE_CLEAN_APP${COLOR_33}'的全部数据...${COLOR_0}"
                    if [ -z "$SELEC_ADB_DEVICE" ]
                    then
                        continue
                    fi
                    ALL_CLEAN_APP=$((ALL_CLEAN_APP + 1))
                    DATA_SIZE="$(adb -s "$SELEC_ADB_DEVICE" shell df /data | awk 'NR==2 {printf "%.2f", ($3/1024/1024)}' 2>>$MST_LOG)"
                    if echo -e -n "$COLOR_30" && adb -s "$SELEC_ADB_DEVICE" shell pm clear "$ONE_CLEAN_APP" </dev/null
                    then
                        OKAY_CLEAN_APP=$((OKAY_CLEAN_APP + 1))
                        RM_DATA_MB="$(awk '{printf "%.2f", ($1 - $2) * 1024}' <<< "$DATA_SIZE $(adb -s "$SELEC_ADB_DEVICE" shell df /data | awk 'NR==2 {printf "%.2f", ($3/1024/1024)}' 2>>$MST_LOG)" 2>>$MST_LOG)"
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}数据清理成功 本次约释放'${COLOR_36}$RM_DATA_MB${COLOR_33}MB'存储空间${COLOR_0}"
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}无法通过ADB命令删除'${COLOR_36}$ONE_CLEAN_APP${COLOR_33}'的全部数据${COLOR_0}"
                        echo
                        echo -e "${COLOR_35}[CMD]${COLOR_33}尝试手动执行命令: ${COLOR_36}adb -s "$SELEC_ADB_DEVICE" shell pm clear "$ONE_CLEAN_APP"${COLOR_0}"
                   fi
                done <<< "$USR_OKAY_PKGE"
                REBOOT_FL || return 0
                ;;
            '6')
                MAIN_REBOOT || return 0
                ;;
            *)
                ERROR_CONT
                ;;
            esac
            ;;
        '3' | 'CMD' | '打开ADBShell')
            MISHUI_MAIN_TIP=打开ADBShell
            SEE_USB_DEVICES
            echo -e "${COLOR_35}[CMD]${COLOR_33}输入可运行于'${COLOR_36}adb${COLOR_33}'的命令 执行'${COLOR_36}exit${COLOR_33}'命令即可退出${COLOR_0}"
            while true
            do
                
                read -e -p $'\001\033[0;35;1m\002[>_]\001\033[0;33;1m\002输入命令:\001\033[0;32;1m\002adb -s '"$SELEC_ADB_DEVICE"$' \001\033[0;1m\002' ADB_SHELL_CMD
                if [ -z "$ADB_SHELL_CMD" ]
                then
                    continue
                elif [[ "$ADB_SHELL_CMD" == exit* ]]
                then
                    REBOOT_FL || return 0
                else
                    if [[ "$ADB_SHELL_CMD" == adb* ]]
                    then
                        ADB_SHELL_CMD="${ADB_SHELL_CMD#adb}"
                    fi
                    if eval "adb -s $SELEC_ADB_DEVICE $ADB_SHELL_CMD"
                    then
                        echo -e "${COLOR_32} - 执行成功${COLOR_0}"
                    else
                        echo -e "${COLOR_31} - 执行失败${COLOR_0}"
                    fi
                    continue
                fi
            done
            REBOOT_FL || return 0
            ;;
        '4' | 'SET' | '高级系统设置')
            MISHUI_MAIN_TIP=高级系统设置
            MISHUI_MAIN
            echo
            ALL_TIP_TION="${COLOR_35}[SET]${COLOR_33}选择对目标设备的设置/修改项 >>${COLOR_0}"
            ALL_OPTION=("1*-修改/恢复目标设备屏幕比例" "2*-设置目标设备墓碑模式" "3*-返回主页")
            NOW_LINE
            SHOW_FUNC_MENU
            case "$FUNC_CONT" in
            '1')
                MISHUI_MAIN_TIP=修改/恢复屏幕分辨率
                SEE_USB_DEVICES
                SAVE_THE_NEW_SIZE() {
                    if ! BAK_ADB_SIZE="$(adb -s "$SELEC_ADB_DEVICE" shell wm size 2>>$MST_LOG | sed 's/.*size: //g')" && [ -z "$BAK_ADB_SIZE" ]
                    then
                        echo -e "${COLOR_35}[WARN]${COLOR_31}无法备份目标设备当前屏幕分辨率 继续执行可能含有风险${COLOR_33} 是否继续 >>${COLOR_0}"
                        echo -e "${COLOR_36}[+][1›确认风险并继续/2›取消并返回主页]*ᐷ${COLOR_01}"
                        read CONTINUE_SET_SIZE
                        case "$CONTINUE_SET_SIZE" in
                            '1' | 'y' | 'Y')
                            echo -e "${COLOR_32}[CONTINUE]${COLOR_33}已确认继续操作 >>${COLOR_0}"
                            ;;
                        *)
                            MAIN_REBOOT || return 0
                            ;;
                        esac
                    fi
                    echo -e "${COLOR_35}[BAK]${COLOR_33}已备份当前屏幕分辨率:${COLOR_36}$BAK_ADB_SIZE${COLOR_0}"
                }
                SET_THE_BAK_SIZE() {
                    echo -e "${COLOR_35}[Restoring]${COLOR_33}正在将目标设备恢复至'${COLOR_36}$BAK_ADB_SIZE${COLOR_33}'分辨率...${COLOR_30}"
                    if adb -s "$SELEC_ADB_DEVICE" shell wm size $BAK_ADB_SIZE
                    then
                        echo -e "${COLOR_32}[OKAY]${COLOR_33}原分辨率恢复成功:${COLOR_36}$BAK_ADB_SIZE${COLOR_0}"
                        REBOOT_FL || return 0
                    else
                        echo -e "${COLOR_31}[ERROR]${COLOR_33}原分辨率恢复失败${COLOR_0}"
                        echo -e "${COLOR_35}[Tip]${COLOR_33}尝试手动执行命令以恢复 必要/极端情况下可前往'${COLOR_36}主页>ADB调试工具>重启连接设备>重启至系统模式${COLOR_33}'功能强制重启目标设备以恢复${COLOR_0}"
                        REBOOT_FL || return 0
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
                echo -e -n "${COLOR_33}[格式:${COLOR_36}1080/2400${COLOR_33}]:${COLOR_01}"
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
                    echo -e "${COLOR_35}[Tip]${COLOR_33}输入必须为'${COLOR_36}1080/1920${COLOR_33}'或'${COLOR_36}1080x1920${COLOR_33}'或'${COLOR_36}1080×1920${COLOR_33}'三种格式其中一种${COLOR_0}"
                    REBOOT_FL || return 0
                    ;;
                esac
                if adb -s "$SELEC_ADB_DEVICE" shell wm size $SETTING_SIZE
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}设置成功 现在测试目标设备能否正常操作触摸并依据测试结果选择操作 >>${COLOR_0}"
                    echo -e "${COLOR_36}[+][1›屏幕正常并确认修改/2›屏幕失效立即恢复]*ᐷ${COLOR_01}"
                    read INPUT_THE_SIZE_YN
                    case "$CONTINUE_SET_SIZE" in
                    '1' | 'y' | 'Y')
                        echo -e "${COLOR_32}[DONE]${COLOR_33}操作已全部完成 目标设备原始分辨率(${COLOR_36}$BAK_ADB_SIZE${COLOR_33})已保存至当前进程 在未重启/未结束当前脚本进程前均可通过再次进入该功能恢复原分辨率${COLOR_0}"
                        ;;
                    *)
                        SET_THE_BAK_SIZE
                        ;;
                    esac
                    REBOOT_FL || return 0
                else
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}设置失败 尝试手动执行命令 >>${COLOR_0}"
                    echo -e "${COLOR_35}[CMD]${COLOR_33}命令: ${COLOR_36}adb -s $SELEC_ADB_DEVICE shell wm size $SETTING_SIZE${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                ;;
            '2')
                MISHUI_MAIN_TIP=设置墓碑模式
                SEE_USB_DEVICES
                START_OUT_THE_PAS() {
                    local FALSE_PAS
                    echo -e "${COLOR_35}[$3]${COLOR_33}是否$2墓碑模式 >>${COLOR_0}"
                    echo -e -n "${COLOR_36}[+][1›$2墓碑模式/2›保持现状并返回主页]*ᐷ${COLOR_01}"
                    read FALSE_PAS
                    case "$FALSE_PAS" in
                    '1' | 'y' | 'Y')
                        if adb -s "$SELEC_ADB_DEVICE" shell settings put global cached_apps_freezer $1
                        then
                            echo -e "${COLOR_32}[OKAY]${COLOR_33}已修改 重启后生效${COLOR_0}"
                            echo -e "${COLOR_35}[STEP]${COLOR_33}重启:${COLOR_36}MST主页 ${COLOR_33}-> ${COLOR_36}ADB调试工具 ${COLOR_33}-> ${COLOR_36}重启连接设备 ${COLOR_33}-> ${COLOR_36}重启至系统${COLOR_0}"
                            REBOOT_FL || return 0
                        else
                            echo -e "${COLOR_31}[ERROR]${COLOR_33}修改失败 尝试手动执行命令${COLOR_0}"
                            echo -e "${COLOR_35}[CMD]${COLOR_33}命令:${COLOR_36}adb -s "$SELEC_ADB_DEVICE" shell settings put global cached_apps_freezer $1${COLOR_0}"
                            REBOOT_FL || return 0
                        fi
                        ;;
                    *)
                        MAIN_REBOOT || return 0
                        ;;
                    esac
                }
                echo -e -n "${COLOR_35}[PAS]${COLOR_33}正在检查目标设备是否支持墓碑模式:${COLOR_0}"
                case "$(adb -s "$SELEC_ADB_DEVICE" shell settings get global cached_apps_freezer)" in
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
                    REBOOT_FL || return 0
                    ;;
                esac
                ;;
            '3')
                MAIN_REBOOT || return 0
                ;;
            *)
                ERROR_CONT
                ;;
            esac
            REBOOT_FL || return 0
            ;;
        '5' | 'RE' | '重启连接设备')
            MISHUI_MAIN_TIP=重启连接设备
            SEE_USB_DEVICES
            ALL_TIP_TION="${COLOR_35}[RE]${COLOR_33}选择需要重启的目标模式 >>${COLOR_0}"
            REBOOT_USB_DEVICES
            ;;
        '6' | 'HOME' | '返回主页')
            MAIN_REBOOT || return 0
            ;;
        *)
            if [ -z "$FUNC_CONT" ]
            then
                echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
                sleep 0.3
                MAIN_REBOOT || return 0
            fi
            echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$FUNC_CONT${COLOR_33}'非菜单中的选项${COLOR_0}"
            REBOOT_FL || return 0
            ;;
        esac
        ;;
    '4' | 'UBL' | '解锁BL锁(第三方工具')
        ADB_FASTBOOT_NAME=FASTBOOT
        ADB_FASTBOOT_CMD=fastboot
        MISHUI_MAIN_TIP=BootLoader解锁
        MISHUI_MAIN
        echo
        echo -e "${COLOR}[UBL]${COLOR_33}支持为一加/小米设备解锁BootLoader >>${COLOR_0}"
        echo
        WARN_UNLOCK_BL() {
            local UNLOCK_BOOTLOADER_YN
            echo -e "${COLOR_35}[WARN]${COLOR_31}解锁设备的BootLoader将使设备失去保修/安全性下降 ${COLOR_33}是否继续 >>${COLOR_0}"
            echo -e -n "${COLOR_36}[+][1›已知晓并继续/2›立即中断并退出]*ᐷ${COLOR_01}"
            read UNLOCK_BOOTLOADER_YN
            case "$UNLOCK_BOOTLOADER_YN" in
            '1' | 'y' | 'Y')
                echo -e "${COLOR_35}[INFO]${COLOR_33}即将开始解锁 确保目标设备已开启'${COLOR_36}OEM解锁${COLOR_33}'选项${COLOR_0}"
                ;;
            *)
                MAIN_REBOOT || return 0
                ;;
            esac
        }
        ALL_TIP_TION="${COLOR_35}[DEV]${COLOR_33}选择目标设备类型 >>${COLOR_0}"
        ALL_OPTION=("1*-一加(OnePlus)-命令解锁" "2*-Xiaomi/Redmi-第三方工具解锁" "3*-返回主页")
        NOW_LINE
        SHOW_FUNC_MENU
        case "$FUNC_CONT" in
        '1')
            MISHUI_MAIN_TIP='解锁一加(OnePlus)'
            SEE_USB_DEVICES
            WARN_UNLOCK_BL
            echo -e "${COLOR_35}[Unlocking]${COLOR_33}正在使用'${COLOR_36}fastboot -s "$SELEC_FASTBOOT_DEVICE" flashing unlock${COLOR_33}'命令解锁...${COLOR_0}"
            if fastboot -s "$SELEC_FASTBOOT_DEVICE" flashing unlock || fastboot -s "$SELEC_FASTBOOT_DEVICE" oem unlock
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}命令执行成功${COLOR_0}"
                echo -e "${COLOR_35}[Tip]${COLOR_33}目标设备跳转页面后点击目标设备'${COLOR_36}音量-${COLOR_33}'键选择'${COLOR_36}UNLOCK THE BOOTLOADER${COLOR_33}'选项并使用关机键确定即可完成解锁${COLOR_0}"
                REBOOT_FL || return 0
            else
                echo -e "${COLOR_31}[ERROR]${COLOR_33}命令执行失败 可能因为Termux没有足够权限或者设备意外断开${COLOR_0}"
                REBOOT_FL || return 0
            fi
            ;;
        '2')
            MISHUI_MAIN_TIP=解锁Xiaomi/Redmi
            SEE_USB_DEVICES
            WARN_UNLOCK_BL
            echo -e "${COLOR_35}[GitHub]${COLOR_33}此处引用GitHub仓库'${COLOR_32}https://github.com/offici5l/MiUnlockTool${COLOR_33}'中${COLOR_36}miunlock${COLOR_33}工具的安装脚本 开发者:${COLOR_36}offici5l${COLOR_0}"
            echo -e "${COLOR_35}[Apache-2.0]${COLOR_32}Copyright (c) 2024 offici5l${COLOR_0}"
            echo
            echo -e "${COLOR_35}[NE]${COLOR_33}是否立即安装第三方${COLOR_36}miunlock${COLOR_33}解锁工具 >>${COLOR_0}"
            echo -e -n "${COLOR_36}[+][1›立即安装/2›返回主页]*ᐷ${COLOR_01}"
            read YN_UPDATE
            case "$YN_UPDATE" in
            '1' | 'y' | 'Y')
                echo -e "${COLOR_35}[Tip]${COLOR_33}长时间未开始安装尝试连接魔法后再试${COLOR_0}"
                echo
                echo -e "${COLOR_35}[Installing]${COLOR_33}正在安装第三方BootLoader解锁工具:${COLOR_36}miunlock${COLOR_0}...${COLOR_0}"
                if curl -sS https://raw.githubusercontent.com/offici5l/MiUnlockTool/main/.install | bash; CLEAR_READ_INPUT
                then
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}工具'${COLOR_36}miunlock${COLOR_33}'安装成功${COLOR_0}"
                    echo
                    ENTER_ANY_CONTINUE
                    sleep 0.5
                    miunlock
                    echo -e "${COLOR_35}[BACK]${COLOR_33}已返回脚本${COLOR_0}"
                    REBOOT_FL || return 0
                else
                    unset INSTALL_ADB_FB_CLI
                    echo -e "${COLOR_31}[ERROR]${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}安装失败 尝试手动执行命令 >>${COLOR_0}"
                    echo -e "${COLOR_33} - 命令: ${COLOR_36}curl -sS https://raw.githubusercontent.com/offici5l/MiUnlockTool/main/.install | bash${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                ;;
            *)
                MAIN_REBOOT || return 0
                ;;
            esac
            REBOOT_FL || return 0
            ;;
        '3')
            MAIN_REBOOT || return 0
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
        echo -e "${COLOR_35}[GitHub]${COLOR_33}此处引用GitHub仓库'${COLOR_32}https://github.com/nohajc/termux-adb${COLOR_33}'中${COLOR_36}ADB&Fastboot${COLOR_33}工具的安装脚本 开发者:${COLOR_36}nohajc${COLOR_0}"
        echo -e "${COLOR_35}[MIT]${COLOR_32}Copyright (c) 2022 nohajc${COLOR_0}"
        echo
        echo -e "${COLOR_35}[NE]${COLOR_33}是否立即安装第三方${COLOR_36}ADB&Fastboot${COLOR_33}命令 >>${COLOR_0}"
        echo -e -n "${COLOR_36}[+][1›立即安装/2›返回主页]*ᐷ${COLOR_01}"
        read YN_UPDATE
        case "$YN_UPDATE" in
        '1' | 'y' | 'Y')
            echo -e "${COLOR_35}[Tip]${COLOR_33}长时间未开始安装尝试连接魔法再试${COLOR_0}"
            echo
            echo -e "${COLOR_35}[Installing]${COLOR_33}正在安装第三方${COLOR_36}ADB&Fastboot${COLOR_33}命令...${COLOR_0}"
            if curl -sS https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash; CLEAR_READ_INPUT
            then
                echo -e "${COLOR_32}[OKAY]${COLOR_33}工具包'${COLOR_36}ADB&Fastboot${COLOR_33}'安装成功${COLOR_0}"
                ADB_FASTBOOT_VER
                REBOOT_FL || return 0
            else
                unset INSTALL_ADB_FB_CLI
                echo -e "${COLOR_31}[ERROR]${COLOR_36}$NOT_INSTALL_TOOLS${COLOR_33}安装失败 尝试手动执行命令 >>${COLOR_0}"
                echo -e "${COLOR_33} - 命令: ${COLOR_36}curl -s https://raw.githubusercontent.com/nohajc/termux-adb/master/install.sh | bash${COLOR_0}"
                REBOOT_FL || return 0
            fi
            ;;
        *)
            MAIN_REBOOT || return 0
            ;;
        esac
        ;;
    '6' | '关于/帮助/更新' | '&')
        MISHUI_MAIN_TIP=关于/帮助/更新
        MISHUI_MAIN
        echo
        ALL_TIP_TION="${COLOR_35}[&]${COLOR_33}选择要进行的操作 >>${COLOR_0}"
        ALL_OPTION=("1*-关于MiShuiTool" "2*-查看常见问题解答" "3*-云更新MST工具箱" "4*-返回主页")
        NOW_LINE
        SHOW_FUNC_MENU
        case "$FUNC_CONT" in
        '1')
            MISHUI_MAIN_TIP=关于MiShuiTool
            MISHUI_MAIN
            echo
            echo -e "${COLOR_35}[MST]${COLOR_33}工具名称: ${COLOR_36}MiShuitool(MST工具箱)${COLOR_33} - ${COLOR_32}CLI${COLOR_0}"
            echo -e "${COLOR_35}[BETA]${COLOR_33}当前版本: ${COLOR_32}$MST_UPDATE_TIME${COLOR_0}"
            echo -e "${COLOR_35}[CE]${COLOR_33}运行环境: ${COLOR_36}Android-Termux ${COLOR_32}Bash 5.2+${COLOR_0}"
            echo -e "${COLOR_35}[Apache-2.0]${COLOR_32} copyright (C) 2026 XaHuizon${COLOR_0}"
            echo
            echo -e "${COLOR_35}[TXT]${COLOR_33}工具介绍 >>${COLOR_0}"
            echo -e "${COLOR_37}    本工具旨在为${COLOR_36}无PC环境${COLOR_37}但需要使用ADB&Fastboot功能的用户提供一个方便的${COLOR_36}Termux${COLOR_37}刷机环境 其中针对${COLOR_36}ADB${COLOR_37}及${COLOR_36}Fastboot${COLOR_37}的部分常用操作均提供了高度自动化的快捷功能${COLOR_0}"
            echo -e "${COLOR_37}    脚本内置大量的检测逻辑 但是百密终有一疏 执行高危操作前务必备份好数据 对于不了解的操作一定要了解清楚后再继续${COLOR_0}"
            echo -e "${COLOR_35}[INFO]${COLOR_33}使用此工具即代表您愿意承担一切潜在风险${COLOR_0}"
            echo
            echo -e "${COLOR_35}[GitHub]${COLOR_33}仓库地址:${COLOR_32} https://github.com/XaHuizon/MiShuiTool-MST${COLOR_0}"
            echo -e "${COLOR_35}[Email]${COLOR_33}联系/反馈: ${COLOR_36}639428035@qq.com${COLOR_0}"
            echo
            echo -e "${COLOR_35}[ACK]${COLOR_33}感谢以下开源项目提供支持! 如果您认为他们还不错 请为他们点上一颗Star!${COLOR_0}"
            echo -e "${COLOR_35}[Apache-2.0]${COLOR_32} Copyright (c) 2024 offici5l${COLOR_0}"
            echo -e "${COLOR_35}[GitHub]${COLOR_33}仓库地址: ${COLOR_32}https://github.com/offici5l/MiUnlockTool${COLOR_0}"
            echo -e "${COLOR_33} - 开发者:${COLOR_36}offici5l${COLOR_0}"
            echo
            echo -e "${COLOR_35}[MIT]${COLOR_32} Copyright (c) 2022 nohajc${COLOR_0}"
            echo -e "${COLOR_35}[GitHub]${COLOR_33}仓库地址: ${COLOR_32}https://github.com/nohajc/termux-adb${COLOR_0}"
            echo -e "${COLOR_33} - 开发者:${COLOR_36}nohajc${COLOR_0}"
            echo
            REBOOT_FL || return 0
            ;;
        '2')
            MISHUI_MAIN_TIP=常见问题解答
            MISHUI_MAIN
            echo
            echo -e "${COLOR_33}问:${COLOR_36}为什么自动连接ADB设备时总失败?${COLOR_0}"
            echo -e "${COLOR_33}答:${COLOR_32}截至本工具发布日期 从 pkg install android-tools 安装的ADB&Fastboot工具不支持在NoRoot模式下通过 termux-usb 连接，由脚本中'[INST]›5*-安装第三方Termux-Fastboot&ADB工具'功能安装的ADB&Fastboot工具经测试可直接连接ADB设备${COLOR_0}"
            echo
            echo -e "${COLOR_33}问:${COLOR_36}为什么在安装第三方工具时总是卡死?${COLOR_0}"
            echo -e "${COLOR_33}答:${COLOR_32}联网的时候科学一点即可${COLOR_0}"
            echo
            echo -e "${COLOR_33}问:${COLOR_36}刷入boot后开不了机只能进Fastboot模式怎么办?${COLOR_0}"
            echo -e "${COLOR_33}答:${COLOR_32}检查BOOT文件是否是对应目标机型的文件 若确定文件与机型匹配则尝试通过脚本中的 [FB]›2*-Fastboot刷机工具 -> [BOOT]›1*-刷入BOOT 功能刷入原版BOOT后再尝试开机${COLOR_0}"
            echo
            REBOOT_FL || return 0
            ;;
        '3')
            MISHUI_MAIN_TIP=云更新MST工具箱
            MISHUI_MAIN
            echo
            MST_FILE_PATH="$PREFIX/bin/mishuitool"
            mkdir -p $MST_HOME/Update &>>$MST_LOG
            MISHUITOOL_URL="$(base64 -d <<< aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL1hhSHVpem9uL01pU2h1aVRvb2wtTVNUL21haW4vTWlTaHVpVG9vbC5iYXNoCg== 2>>$MST_LOG)"
            echo -e "${COLOR_35}[UP]${COLOR_33}云更新功能基于GitHub仓库实现 >>${COLOR_0}"
            if ! mkdir -p $MST_HOME/Update && rm -rf $MST_HOME/Update/* &>>$MST_LOG
            then
                echo -e "${COLOR_31}[ERROR]${COLOR_33}无法创建云更新所需要的文件夹:${COLOR_36}$MST_HOME/Update${COLOR_0}"
                REBOOT_FL || return 0
            fi
            echo -e -n " ${COLOR_35}[CU]${COLOR_33}正在检测更新...${COLOR_0}\r"
            if ! curl -o $MST_HOME/Update/version.txt "$(base64 -d <<< aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL1hhSHVpem9uL01pU2h1aVRvb2wtTVNUL21haW4vVmVyc2lvbi9HaXRIdWItVmVyc2lvbgo=)" &>>$MST_LOG || ! [ -f "$MST_HOME/Update/version.txt" ]
            then
                rm -rf $MST_HOME/Update/
                echo -e "${COLOR_31}[ERROR]${COLOR_33}检测更新失败 检查网络是否连接或使用魔法再试一次${COLOR_0}"
                REBOOT_FL || return 0
            fi
            NEW_VERSION_NUMB="$(sed -n 1p "$MST_HOME/Update/version.txt")"
            NEW_VERSION_TIME="$(sed -n 2p "$MST_HOME/Update/version.txt")"
            echo -e "\033[2K"
            DOWNLOAD_MISHUITOOL() {
                echo
                echo -e "${COLOR_35}[$1]${COLOR_33}$2 >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›$3/2›返回主页]*ᐷ${COLOR_01}"
                read YN_CURL
                case "$YN_CURL" in
                '2' | 'n' | 'N' | '否')
                    rm -rf $MST_HOME/Update/* &>>$MST_LOG
                    MAIN_REBOOT || return 0
                    ;;
                esac
                echo -e "${COLOR_35}[Download]${COLOR_33}正在下载云端最新MiShuiTool进行覆盖更新...${COLOR_0}"
                if curl -o "$MST_HOME/Update/MiShuiTool" "$MISHUITOOL_URL" -o $MST_HOME/assets/Text/MST-Head.txt "$(base64 -d <<< "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL1hhSHVpem9uL01pU2h1aVRvb2wtTVNUL21haW4vYXNzZXRzL1RleHQvTVNULUhlYWQudHh0Cg==")" &>>$MST_LOG && shc -rf "$MST_HOME/Update/MiShuiTool" -o "$MST_FILE_PATH" &>>$MST_LOG && chmod 777 "$MST_FILE_PATH"
                then
                    rm $MST_HOME/Update/MiShuiTool
                    echo -e "${COLOR_32}[OKAY]${COLOR_33}覆盖更新完成 文件路径:${COLOR_36}$MST_FILE_PATH${COLOR_0}"
                else
                    rm $MST_HOME/Update/MiShuiTool
                    echo -e "${COLOR_31}[ERROR]${COLOR_33}下载失败 检查网络连接或使用魔法后再试一次${COLOR_0}"
                    REBOOT_FL || return 0
                fi
                echo
                echo -e "${COLOR_35}[RE]${COLOR_33}覆盖更新后需要重启MST才能应用 >>${COLOR_0}"
                echo -e -n "${COLOR_36}[+][1›重启MST/2›退出MST]*ᐷ${COLOR_01}"
                read YN_FIX_RE_MST
                case "$YN_FIX_RE_MST" in
                '1' | 'y' | 'Y')
                    echo -e -n " ${COLOR_35}[Rebooting]${COLOR_33}正在重启MST...${COLOR_0}\r"
                    sleep 0.3
                    exec "$MST_FILE_PATH" && exit 0
                    ;;
                *)
                    EXIT_SHELL
                    ;;
                esac
            }
            if [ "$NOW_VERSION" -ge "$NEW_VERSION_NUMB" ]
            then
                echo -e "${COLOR_35}[VER]${COLOR_33}当前版本:${COLOR_36}$MST_UPDATE_TIME${COLOR_33}-${COLOR_32}已是最新版本${COLOR_0}"
                DOWNLOAD_MISHUITOOL FIX "是否立即下载最新版本MST修复本地文件" "下载修复"
            fi
            echo -e "${COLOR_35}[NEW]${COLOR_33}发现新版本:${COLOR_32}$NEW_VERSION_TIME${COLOR_0}"
            echo
            echo -e "${COLOR_35}[Update]${COLOR_33}本次更新 >>${COLOR_0}"
            echo -e "${COLOR_32}[>]${COLOR_33}[版本:${COLOR_36}$MST_UPDATE_TIME ${COLOR_35}->${COLOR_33} ${COLOR_36}$NEW_VERSION_TIME${COLOR_33}]${COLOR_0}"
            echo -e -n " ${COLOR_35}[LOG]${COLOR_33}正在获取本次更新内容...${COLOR_0}\r"
            if ! curl -o $MST_HOME/Update/Update.log "$(base64 -d <<< aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL1hhSHVpem9uL01pU2h1aVRvb2wtTVNUL21haW4vVmVyc2lvbi9VcGRhdGUubG9nCg==)" &>>$MST_LOG
            then
                echo -e "\n${COLOR_31}[ERROR]${COLOR_33}更新日志获取失败${COLOR_0}"
            else
                echo -e "\033[K${COLOR_35}[LOG]${COLOR_33}本次更新内容 >>${COLOR_0}"
                sleep 0.02
                while IFS= read READ_ONE_LOG
                do
                    echo -e "${COLOR_36}$READ_ONE_LOG${COLOR_0}"
                    sleep 0.03
                done < "$MST_HOME/Update/Update.log"
            fi
            DOWNLOAD_MISHUITOOL DL "是否立即下载更新最新版本MiShuiTool" "下载更新"
            ;;
        '4')
            MAIN_REBOOT || return 0
            ;;
        *)
            ERROR_CONT
            ;;
        esac
        
        REBOOT_FL || return 0
        ;;
    '7' | '退出MST工具箱' | 'EXIT')
        EXIT_SHELL
        ;;
    *)
        if [ -z "$INPUT_USR" ]
        then
            echo -e "${COLOR_31}[!]${COLOR_33}此处不可为空${COLOR_0}"
            sleep 0.3
            MAIN_REBOOT || return 0
        fi
        echo -e "${COLOR_31}[!]${COLOR_33}'${COLOR_36}$INPUT_USR${COLOR_33}'非菜单中的选项${COLOR_0}"
        REBOOT_FL || return 0
    ;;
    esac
}
case "$1" in
'')
    true
    ;;
update | -u | --update)
    echo
    curl -sS https://raw.githubusercontent.com/XaHuizon/MiShuiTool-MST/main/install | bash
    exit 0
    ;;
help | -h | --help)
    echo
    echo "mishuitool支持使用选项快捷完成一些操作"
    echo -e "在 ${COLOR_32}mishuitool${COLOR_0} 命令后添加以下选项即可快捷启动对应功能"
    echo
    echo -e " ${COLOR_32}update${COLOR_0}  | ${COLOR_32}-u ${COLOR_0}| ${COLOR_32}--update${COLOR_0}   更新MST工具箱"
    echo -e " ${COLOR_32}version${COLOR_0} | ${COLOR_32}-v ${COLOR_0}| ${COLOR_32}--version${COLOR_0}  查看MST工具箱的版本信息"
    echo -e " ${COLOR_32}check${COLOR_0}   | ${COLOR_32}-c ${COLOR_0}| ${COLOR_32}--check${COLOR_0}    快速检查运行环境"
    echo
    exit 0
    ;;
version | -v | --version)
    echo
    echo -e " - ${COLOR_32}MiShuiTool${COLOR_36} (MST工具箱)${COLOR_0} >>"
    echo -e "版本: ${COLOR_36}$MST_UPDATE_TIME ${COLOR_32}CLI (基于命令行)${COLOR_0}"
    echo -e "运行环境:  ${COLOR_32}Linux-Android-Termux Bash 5.2+${COLOR_0}"
    echo -e "Gitee地址: ${COLOR_32}https://gitee.com/XaHui-GitHub/mi-shui-tool/${COLOR_0}"
    echo
    echo -e "${COLOR_35}INFO:${COLOR_0}作者不保证此工具没有任何BUG 仅供交流学习 使用前务必备份好重要数据${COLOR_0}"
    echo -e "${COLOR_35}Email: ${COLOR_32}311461xhl@gmail.com${COLOR_0}"
    echo
    exit 0
    ;;
check | -c | --check)
    echo
    echo "Check:正在检查当前环境..."
    echo -e -n "${COLOR_35}所需命令: ${COLOR_36}adb${COLOR_0}"
    if command -v adb &>>$MST_LOG
    then
        echo -e " ------------------ ${COLOR_32}[OKAY]${COLOR_0}"
    else
        echo -e "${COLOR_31}[Not Found]${COLOR_0}"
        echo -e "${COLOR_31}ERROR:${COLOR_36}adb${COLOR_0}命令未安装/不可用!${COLOR_0}"
    fi
    echo -e -n "${COLOR_35}所需命令: ${COLOR_36}fastboot${COLOR_0}"
    if command -v fastboot &>>$MST_LOG
    then
        echo -e " ------------- ${COLOR_32}[OKAY]${COLOR_0}"
    else
        echo -e "${COLOR_31}[Not Found]${COLOR_0}"
        echo -e "${COLOR_31}ERROR:${COLOR_36}adb${COLOR_0}命令未安装/不可用!${COLOR_0}"
    fi
    echo -e -n "${COLOR_35}Bash版本: ${COLOR_36}"
    if BASH_VERSION="$(bash --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)" && [ "$BASH_VERSION" > 5.2.0 ]
    then
        echo -e "$BASH_VERSION ${COLOR_0}---------------- ${COLOR_32}[OKAY]${COLOR_0}"
    else
        echo -e "${COLOR_31}[OLD]${COLOR_0}"
        echo -e "${COLOR_31}ERROR:${COLOR_0}Bash版本过低 MST运行需要bash5.2+"
    fi
    echo -e -n "${COLOR_35}PATH路径: ${COLOR_36}"
    if [[ "$PATH" = **/data/data/com.termux/files/usr/bin** ]]
    then
        echo -e ".../com.termux/.../bin ${COLOR_32}[OKAY]${COLOR_0}"
    else
        echo -e "$PATH ${COLOR_31}[ERROR]${COLOR_0}"
        echo -e "${COLOR_31}ERROR:${COLOR_0}当前环境似乎不是Termux"
    fi
    echo -e -n "${COLOR_35}脚本权限: ${COLOR_36}"
    case "$(id -u)" in
    0)
        echo -e "ROOT (0)${COLOR_0} ------------- ${COLOR_32}[OKAY]${COLOR_0}"
        ;;
    2000)
        echo -e "SHELL (2000)${COLOR_0} --------- ${COLOR_32}[OKAY]${COLOR_0}"
        ;;
    *)
        echo -e "USER ($(id -u))${COLOR_0} --------- ${COLOR_32}[OKAY]${COLOR_0}"
        ;;
    esac
    echo 
    exit 0
    ;;
*)
    echo
    echo -e "执行 ${COLOR_32}mishuitool help${COLOR_0} 命令以查看MST支持哪些选项及其功能"
    echo
    exit 1
    ;;
esac
if [ ! -d $HOME/MST/ ]
then
    if mkdir -p $HOME/MST &>>$MST_LOG
    then
        HEAD_TIP_MISHUITOOL="${COLOR_32}Okay:${COLOR_31}已自动初始化运行环境${COLOR_0}"
    else
        HEAD_TIP_MISHUITOOL="${COLOR_31}Error:${COLOR_31}初始化运行环境失败 需重启脚本${COLOR_0}"
        EXIT_SHELL 1
    fi
fi

trap wait EXIT
if [ ! -f "$HOME/MST/MST运行日志.log" ]
then
    mkdir -p $HOME/MST/ &>>$MST_LOG
    touch $MST_LOG
elif [ "$(stat -c%s $HOME/MST/MST运行日志.log)" -gt 10240 ]
then
    echo "[$(date +%Y-%m-%d) $(date +%H:%M:%S)] 日志文件过大已自动清除" &>$MST_LOG
fi
mkdir -p $MST_HOME/assets/Text/ &>>$MST_LOG
bash -c true
if [ "$COLUMNS" -lt "65" ]
then
     MAIN_HAED_TIP
     echo -e "${COLOR_35}[INFO]${COLOR_33}当前终端宽度过窄 为保证视觉效果需将终端宽度调整为'${COLOR_36}65${COLOR_33}'${COLOR_0}"
    echo -e "${COLOR_35}[Tip]${COLOR_33}双指捏合屏幕可缩小终端界面 当下方红色长条(${COLOR_36}-----...${COLOR_33})缩为一行后即为调整成功 从此刻开始每${COLOR_36}0.5s${COLOR_33}自动检查一次终端宽度是否合格 如果终端宽度已合格将自动进入主页 检测超${COLOR_36}30s${COLOR_33}则超时退出${COLOR_0}"
    echo -e -n "${COLOR_31}-------------------------------------------------------------------${COLOR_0}"
    while [ "$COLUMNS" -lt 65 ]
    do
        if [ "$TIMEOUT_NUMBER" -lt 60 ]
        then
            echo -e "${COLOR_31}[!]${COLOR_33}已超时自动退出${COLOR_0}"
            EXIT_SHELL 1
        fi
        TIMEOUT_NUMBER=$((TIMEOUT_NUMBER + 1))
        sleep 0.5
    done
    echo -e "${COLOR_32}"
    echo -e "${COLOR_32}[OKAY]${COLOR_33}宽度已合格即将进入主页 如果进入后发现图形错位可尝试退出脚本后使用'${COLOR_36}mishuitool${COLOR_33}'命令重新启动MST工具箱${COLOR_0}"
    sleep 7.5
fi
CA_FLASH_MAIN