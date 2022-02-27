#!/bin/bash
##
#
# SXP Node check & Discord alert script
# Delegate BFX (@Bx64)
#
# Forked from @mtaylan
##

# Source the seperate configuration file (credits to @crna_zmija)
#

. ~/NodeMonitoring/dpos_node_discord.conf

# Fail immediately if another instance is already running
#

export LC_ALL=C.UTF-8
script_name=$(basename -- "$0")

if pidof -x "$script_name" -o $$ >/dev/null ; then
   echo "An another instance of this script is already running, please clear all the sessions of this script before starting a new session"
   exit 1
fi

# Check required packages
#

if ! command -v sar &> /dev/null ; then
    echo "sar command could not be found! Please install sysstat:"
    echo "sudo apt install sysstat"
    exit
fi

if ! command -v jq &> /dev/null ; then
    echo "jq command could not be found! Please install jq:"
    echo "sudo apt-get install jq -y"
    exit
fi

# CLI1: check alert count (relay)
#

function check_alert_count_cli1
{
    if [ ! -f "$FILE_CLI1" ] ; then
        echo "1" > $FILE_CLI1
        COUNTER=$(cat $FILE_CLI1)
    else
        echo $(( $(cat $FILE_CLI1) + 1 ))> $FILE_CLI1
        COUNTER=$(cat $FILE_CLI1)
    fi
    case $COUNTER in
        1) SEND_ALERT_FLAG_CLI1=true ;;
        5) SEND_ALERT_FLAG_CLI1=true ;;
        15) SEND_ALERT_FLAG_CLI1=true ;;
        30) SEND_ALERT_FLAG_CLI1=true ;;
        60) SEND_ALERT_FLAG_CLI1=true ;;
        120) SEND_ALERT_FLAG_CLI1=true ;;
        360) SEND_ALERT_FLAG_CLI1=true ;;
        720) SEND_ALERT_FLAG_CLI1=true ;;
        1440) SEND_ALERT_FLAG_CLI1=true ;;
        *)  SEND_ALERT_FLAG_CLI1=false ;;
    esac
}

# CLI2: check alert count (forger)
#

function check_alert_count_cli2
{
    if [ ! -f "$FILE_CLI2" ] ; then
        echo "1" > $FILE_CLI2
        COUNTER=$(cat $FILE_CLI2)
    else
        echo $(( $(cat $FILE_CLI2) + 1 ))> $FILE_CLI2
        COUNTER=$(cat $FILE_CLI2)
    fi
    case $COUNTER in
        1) SEND_ALERT_FLAG_CLI2=true ;;
        5) SEND_ALERT_FLAG_CLI2=true ;;
        15) SEND_ALERT_FLAG_CLI2=true ;;
        30) SEND_ALERT_FLAG_CLI2=true ;;
        60) SEND_ALERT_FLAG_CLI2=true ;;
        120) SEND_ALERT_FLAG_CLI2=true ;;
        360) SEND_ALERT_FLAG_CLI2=true ;;
        720) SEND_ALERT_FLAG_CLI2=true ;;
        1440) SEND_ALERT_FLAG_CLI2=true ;;
        *)  SEND_ALERT_FLAG_CLI2=false ;;
    esac
}

# CLI3: check alert count (core)
#

function check_alert_count_cli3
{
    if [ ! -f "$FILE_CLI3" ] ; then
        echo "1" > $FILE_CLI3
        COUNTER=$(cat $FILE_CLI3)
    else
        echo $(( $(cat $FILE_CLI3) + 1 ))> $FILE_CLI3
        COUNTER=$(cat $FILE_CLI3)
    fi
    case $COUNTER in
        1) SEND_ALERT_FLAG_CLI3=true ;;
        5) SEND_ALERT_FLAG_CLI3=true ;;
        15) SEND_ALERT_FLAG_CLI3=true ;;
        30) SEND_ALERT_FLAG_CLI3=true ;;
        60) SEND_ALERT_FLAG_CLI3=true ;;
        120) SEND_ALERT_FLAG_CLI3=true ;;
        360) SEND_ALERT_FLAG_CLI3=true ;;
        720) SEND_ALERT_FLAG_CLI3=true ;;
        1440) SEND_ALERT_FLAG_CLI3=true ;;
        *)  SEND_ALERT_FLAG_CLI3=false ;;
    esac
}

# Latency: check alert count
#

function check_alert_count_api
{
    if [ ! -f "$FILE_API" ] ; then
        echo "1" > $FILE_API
        COUNTER=$(cat $FILE_API)
    else
        echo $(( $(cat $FILE_API) + 1 ))> $FILE_API
        COUNTER=$(cat $FILE_API)
    fi
    case $COUNTER in
        1) SEND_ALERT_FLAG_API=true ;;
        5) SEND_ALERT_FLAG_API=true ;;
        15) SEND_ALERT_FLAG_API=true ;;
        30) SEND_ALERT_FLAG_API=true ;;
        60) SEND_ALERT_FLAG_API=true ;;
        120) SEND_ALERT_FLAG_API=true ;;
        360) SEND_ALERT_FLAG_API=true ;;
        720) SEND_ALERT_FLAG_API=true ;;
        1440) SEND_ALERT_FLAG_API=true ;;
        *)  SEND_ALERT_FLAG_API=false ;;
    esac
}

# CPU: check alert count
#

function check_alert_count_cpu
{
    if [ ! -f "$FILE_CPU" ] ; then
        echo "1" > $FILE_CPU
        COUNTER_CPU=$(cat $FILE_CPU)
    else
        echo $(( $(cat $FILE_CPU) + 1 ))> $FILE_CPU
        COUNTER_CPU=$(cat $FILE_CPU)
    fi

    case $COUNTER_CPU in
        1) SEND_ALERT_FLAG_CPU=true ;;
        5) SEND_ALERT_FLAG_CPU=true ;;
        15) SEND_ALERT_FLAG_CPU=true ;;
        30) SEND_ALERT_FLAG_CPU=true ;;
        60) SEND_ALERT_FLAG_CPU=true ;;
        120) SEND_ALERT_FLAG_CPU=true ;;
        360) SEND_ALERT_FLAG_CPU=true ;;
        720) SEND_ALERT_FLAG_CPU=true ;;
        1440) SEND_ALERT_FLAG_CPU=true ;;
        *)  SEND_ALERT_FLAG_CPU=false ;;
    esac
}

# HDD: check alert count
#

function check_alert_count_hdd
{
    if [ ! -f "$FILE_HDD" ] ; then
        echo "1" > $FILE_HDD
        COUNTER_HDD=$(cat $FILE_HDD)
    else
        echo $(( $(cat $FILE_HDD) + 1 ))> $FILE_HDD
        COUNTER_HDD=$(cat $FILE_HDD)
    fi

    case $COUNTER_HDD in
        1) SEND_ALERT_FLAG_HDD=true ;;
        5) SEND_ALERT_FLAG_HDD=true ;;
        15) SEND_ALERT_FLAG_HDD=true ;;
        30) SEND_ALERT_FLAG_HDD=true ;;
        60) SEND_ALERT_FLAG_HDD=true ;;
        120) SEND_ALERT_FLAG_HDD=true ;;
        360) SEND_ALERT_FLAG_HDD=true ;;
        720) SEND_ALERT_FLAG_HDD=true ;;
        1440) SEND_ALERT_FLAG_HDD=true ;;
        *)  SEND_ALERT_FLAG_HDD=false ;;
    esac
}

# Software: check alert count
#

function check_alert_count_sw
{
    if [ ! -f "$FILE_SW" ] ; then
        echo "1" > $FILE_SW
        COUNTER_SW=$(cat $FILE_SW)
    else
        echo $(( $(cat $FILE_SW) + 1 ))> $FILE_SW
        COUNTER_SW=$(cat $FILE_SW)
    fi

    case $COUNTER_SW in
        1) SEND_ALERT_FLAG_SW=true ;;
        5) SEND_ALERT_FLAG_SW=true ;;
        15) SEND_ALERT_FLAG_SW=true ;;
        30) SEND_ALERT_FLAG_SW=true ;;
        60) SEND_ALERT_FLAG_SW=true ;;
        120) SEND_ALERT_FLAG_SW=true ;;
        360) SEND_ALERT_FLAG_SW=true ;;
        720) SEND_ALERT_FLAG_SW=true ;;
        1440) SEND_ALERT_FLAG_SW=true ;;
        *)  SEND_ALERT_FLAG_SW=false ;;
    esac
}

# Blocks: check alert count
#

function check_alert_count_blocks
{
    if [ ! -f "$FILE_BLOCKS" ] ; then
        echo "1" > $FILE_BLOCKS
        COUNTER_BLOCKS=$(cat $FILE_BLOCKS)
    else
        echo $(( $(cat $FILE_BLOCKS) + 1 ))> $FILE_BLOCKS
        COUNTER_BLOCKS=$(cat $FILE_BLOCKS)
    fi

    case $COUNTER_BLOCKS in
        1) SEND_ALERT_FLAG_BLOCKS=true ;;
        5) SEND_ALERT_FLAG_BLOCKS=true ;;
        15) SEND_ALERT_FLAG_BLOCKS=true ;;
        30) SEND_ALERT_FLAG_BLOCKS=true ;;
        60) SEND_ALERT_FLAG_BLOCKS=true ;;
        120) SEND_ALERT_FLAG_BLOCKS=true ;;
        360) SEND_ALERT_FLAG_BLOCKS=true ;;
        720) SEND_ALERT_FLAG_BLOCKS=true ;;
        1440) SEND_ALERT_FLAG_BLOCKS=true ;;
        *)  SEND_ALERT_FLAG_BLOCKS=false ;;
    esac
}

# Discord CLI1 check (relay) - send notification
#

function discord_send_cli1
{
    if [ "$SEND_ALERT_FLAG_CLI1" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Discord CLI2 check (forger) - send notification
#

function discord_send_cli2
{
    if [ "$SEND_ALERT_FLAG_CLI2" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Discord CLI3 check (core) - send notification
#

function discord_send_cli3
{
    if [ "$SEND_ALERT_FLAG_CLI3" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Discord API test, alive/health check & latency - send notification
#

function discord_send_api
{
    if [ "$SEND_ALERT_FLAG_API" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Discord CPU usage - send notification
#

function discord_send_cpu
{
    if [ "$SEND_ALERT_FLAG_CPU" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Discord software version - send notification
#

function discord_send_sw
{
    if [ "$SEND_ALERT_FLAG_SW" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Discord HDD capacity - send notification
#

function discord_send_hdd
{
    if [ "$SEND_ALERT_FLAG_HDD" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Discord API blockheight - send notification.
#

function discord_send_blocks
{
    if [ "$SEND_ALERT_FLAG_BLOCKS" = true ] ; then
        echo " >>>>: sending $MESSAGE"
        $DISCORD --text "$MESSAGE"
    fi
}

# Test message sent to Discord
#

if [ "$1" == "test" ] ; then
    SEND_ALERT_FLAG_CPU=false
    MESSAGE="$(date) - [TEST] SXP node $HOSTNAME TEST message!"
    echo " >>>> : $MESSAGE"
    discord_send_api
    exit 0
fi

# Node alive message sent to Discord every hour
# 

if [[ $ALIVE == "00" ]] ; then
    MESSAGE="$(date) - [SYSTEM] [OK] SXP node $HOSTNAME is alive!"
    echo " >>>> : $MESSAGE"
    discord_send_api
    exit 0
fi

# Health status checks with CLI
#

# Relay process

if $RELAY == true ; then
    if /home/solar/solar-core/packages/core/bin/run $@ --token=solar relay:status | grep online >/dev/null ; then
        if [ -f "$FILE_CLI1" ] ; then
            echo "$FILE_CLI1 exists."
            MESSAGE="$(date) - [INFO] [ALERT RELAY RESOLVED] Solar node $HOSTNAME relay process is online again!"
            rm $FILE_CLI1
            SEND_ALERT_FLAG_CLI1=true
            discord_send_cli1
        else
            echo " >>>> : Solar node $HOSTNAME relay process is online!"
        fi
    else
        check_alert_count_cli1
        MESSAGE="$(date) - [CRITICAL] [ALERT RELAY] Solar node relay process is not online! #count:$COUNTER - hostname=$HOSTNAME"
        echo " >>>> : $MESSAGE"
        discord_send_cli1
    fi
else
    echo " >>>> : Skipping relay process check."
fi

# Forger process

if $FORGER == true ; then
    if /home/solar/solar-core/packages/core/bin/run $@ --token=solar forger:status | grep online >/dev/null ; then
        if [ -f "$FILE_CLI2" ] ; then
            echo "$FILE_CLI2 exists."
            MESSAGE="$(date) - [INFO] [ALERT FORGER RESOLVED] Solar node $HOSTNAME forger process is online again!"
            rm $FILE_CLI2
            SEND_ALERT_FLAG_CLI2=true
            discord_send_cli2
        else
            echo " >>>> : Solar node $HOSTNAME forger process is online!"
        fi
    else
        check_alert_count_cli2
        MESSAGE="$(date) - [CRITICAL] [ALERT FORGER] Solar node forger process is not online! #count:$COUNTER - hostname=$HOSTNAME"
        echo " >>>> : $MESSAGE"
        discord_send_cli2
    fi
else
    echo " >>>> : Skipping forger process check."
fi

# Core process

if $CORE == true ; then
    if /home/solar/solar-core/packages/core/bin/run $@ --token=solar core:status | grep online >/dev/null ; then
        if [ -f "$FILE_CLI3" ] ; then
            echo "$FILE_CLI3 exists."
            MESSAGE="$(date) - [INFO] [ALERT CORE RESOLVED] Solar node $HOSTNAME core process is online again!"
            rm $FILE_CLI3
            SEND_ALERT_FLAG_CLI3=true
            discord_send_cli3
        else
            echo " >>>> : Solar node $HOSTNAME core process is online!"
        fi
    else
        check_alert_count_cli3
        MESSAGE="$(date) - [CRITICAL] [ALERT CORE] Solar node core process is not online! #count:$COUNTER - hostname=$HOSTNAME"
        echo " >>>> : $MESSAGE"
        discord_send_cli3
    fi
else
    echo " >>>> : Skipping core process check."
fi

# Health status check with API call
#

HTTP_CODE=$(curl -s -w '%{http_code}' --connect-timeout 5 --max-time 10 -o /dev/null http://dapi.solar.network/api/peers/$DPOS_NODE_IP)
CURL_STATUS=$?

echo " >>>> : $(date)"
echo " >>>> : TOKEN= $TOKEN"
echo " >>>> : CHAT_ID= $CHAT_ID"
echo " >>>> : HTTP_CODE= $HTTP_CODE"
echo " >>>> : CURL_STATUS= $CURL_STATUS"
echo " >>>> : FILE= $FILE_API"

# Check whether your node is healthy using explorer API

if [ "$CURL_STATUS" -eq 0 ] ; then

    if [[ "$HTTP_CODE" -ne 200 ]] ; then
        check_alert_count_api
        MESSAGE="$(date) - [CRITICAL] [ALERT] SXP node is not found in API call! #count:$COUNTER - returning http_code=$HTTP_CODE hostname=$HOSTNAME"
        echo " >>>> : $MESSAGE"
        discord_send_api
    else
        echo " >>>> : SXP node $HOSTNAME is found in API call!"

        STATUS_HEALTHY=$(curl -sS --max-time 50 --retry 20 --retry-delay 2 --retry-max-time 40 http://dapi.solar.network/api/peers/$DPOS_NODE_IP | jq -r '.data.latency')

        if [[ "$STATUS_HEALTHY" -lt $LATENCY_CRITICAL ]] ; then
            MESSAGE="$(date) - [INFO] SXP node is healthy! - LATENCY(ms)=$STATUS_HEALTHY hostname=$HOSTNAME"
            echo " >>>> : $MESSAGE"
#           echo " >>>> : $STATUS_HEALTHY"
            if [ -f "$FILE_API" ] ; then
                echo "$FILE_API exists."
                MESSAGE="$(date) - [INFO] [ALERT RESOLVED] SXP node is healthy again! - LATENCY(ms)=$STATUS_HEALTHY hostname=$HOSTNAME"
                rm $FILE_API
                SEND_ALERT_FLAG_API=true
                discord_send_api
            fi
        else
            check_alert_count_api
            MESSAGE="$(date) - [CRITICAL] [ALERT LATENCY] SXP node is not healthy! #count:$COUNTER - LATENCY(ms)=$STATUS_HEALTHY hostname=$HOSTNAME"
            echo " >>>> : $MESSAGE"
            discord_send_api
        fi
    fi

else
    check_alert_count_api
    MESSAGE="$(date) - [CRITICAL] [ALERT] SXP node is not found in API call! #count:$COUNTER - hostname=$(hostname)"
    echo " >>>> : $MESSAGE"
    discord_send_api
fi

# Compare blockheight of node with network
#

BLOCK_STATUS_SXP=$(curl -sS --max-time 40 --retry 20 --retry-delay 2 --retry-max-time 40 http://dapi.solar.network/api/blockchain | jq '.data.block.height')
BLOCK_STATUS_NODE=$(curl -sS $LOOPBACK:$API_PORT/api/blockchain | jq .'[].block.height')
BLOCKS_BEHIND="$(($BLOCK_STATUS_SXP - $BLOCK_STATUS_NODE))"

if [[ "$BLOCKS_BEHIND" -lt $MAX_BLOCKS_BEHIND ]] ; then
    MESSAGE="$(date) - [INFO] $HOSTNAME Blockchain sync within acceptable limit! - Blockheight at $HOSTNAME only $BLOCKS_BEHIND blocks behind Solar network"
    echo " >>>> : Blockheight at Solar network=$BLOCK_STATUS_SXP"
    echo " >>>> : Blockheight at $HOSTNAME=$BLOCK_STATUS_NODE"
    echo " >>>> : Blocks behind=$BLOCKS_BEHIND"
    echo " >>>> : $MESSAGE"

    if [ -f "$FILE_BLOCKS" ] ; then
        echo "$FILE_BLOCKS exists."
        MESSAGE="$(date) - [INFO] [ALERT RESOLVED] $HOSTNAME Blocks are behind within acceptable limits ($BLOCKS_BEHIND blocks) - Limit is $MAX_BLOCKS_BEHIND blocks"
        rm $FILE_BLOCKS
        SEND_ALERT_FLAG_BLOCKS=true
        discord_send_blocks
    fi
else
    check_alert_count_blocks
    MESSAGE="$(date) - [CRITICAL] [ALERT BLOCKS] $HOSTNAME Blocks are $BLOCKS_BEHIND blocks behind from Solar network! #count:$COUNTER_BLOCKS - Limit is $MAX_BLOCKS_BEHIND blocks for $HOSTNAME"
    echo " >>>> : $MESSAGE"
    discord_send_blocks
fi

# Compare software version of node with GitHub release
#

SOFTWARE_VERSION=$(/home/solar/solar-core/packages/core/bin/run --token=solar version)
GITHUB_VERSION=$(curl -s https://github.com/Solar-network/core/tags |grep /Solar-network/core/archive/refs/tags/ | head -n 1| cut -d'/' -f7 |awk -F '.zip' '{print $1}')
if [[ "$SOFTWARE_VERSION" == "$GITHUB_VERSION" ]] ; then
    MESSAGE="$(date) - [INFO] Latest software VERSION=$SOFTWARE_VERSION is installed on $HOSTNAME"
    echo " >>>> : $MESSAGE"
    echo " >>>> : Installed Solar-core version $SOFTWARE_VERSION"
    echo " >>>> : Solar-core release $GITHUB_VERSION at GitHub"
    if [ -f "$FILE_SW" ] ; then
        echo "$FILE_SW exists."
        MESSAGE="$(date) - [INFO] [ALERT RESOLVED] Latest software Solar-core $SOFTWARE_VERSION installed on $HOSTNAME"
        rm $FILE_SW
        SEND_ALERT_FLAG_SW=true
        discord_send_sw
    fi
else
    check_alert_count_sw
    MESSAGE="$(date) - [CRITICAL] [ALERT SOFTWARE VERSION] Solar-cli software is outdated! #count:$COUNTER_SW - INSTALLED VERSION=$SOFTWARE_VERSION GITHUB VERSION=$GITHUB_VERSION hostname=$HOSTNAME"                
    echo " >>>> : $MESSAGE"
    discord_send_sw
fi

# Check HDD capacity of your node
#

HDD_USAGE=$(df -H / | grep -vE 'Filesystem' | awk '{ print $5 " " $1 }')
HDD_USED=$(echo $HDD_USAGE | awk '{ print $1}' | cut -d'%' -f1  )
PARTITION=$(echo $HDD_USAGE | awk '{ print $2 }' )

if [[ $HDD_USED -lt $HDD_USE_CRITICAL ]] ; then
    MESSAGE="$(date) - [INFO] The partition \"$PARTITION\" at $HOSTNAME has used $HDD_USED% of total HDD at $(date)"
    echo " >>>> : $MESSAGE"
    echo " >>>> : Partition: $PARTITION"
    echo " >>>> : HDD used %: $HDD_USED"
    if [ -f "$FILE_HDD" ] ; then
        echo "$FILE_HDD exists."
        MESSAGE="$(date) - [INFO] [ALERT RESOLVED] HDD capacity is higher than critical limit ($HDD_USE_CRITICAL%) at $HOSTNAME"
        rm $FILE_HDD
        SEND_ALERT_FLAG_HDD=true
        discord_send_hdd
    fi
else
    check_alert_count_hdd
    MESSAGE="$(date) - [CRITICAL] [ALERT HDD CAPACITY] HDD capacity is lower than critical limit! #count:$COUNTER_HDD - CAPACITY USED=$HDD_USED% at $HOSTNAME"
    echo " >>>> : $MESSAGE"
    discord_send_hdd
fi

# Check CPU usage of your node
#

CPU_LOAD=`sar -P ALL 1 5 | grep "Average.*all" | awk -F" " '{printf "%.2f\n", 100 -$NF}'`

echo " >>>> : CPU_LOAD=$CPU_LOAD"
echo " >>>> : CPU_LOAD_CRITICAL=$CPU_LOAD_CRITICAL"

#if [[ $CPU_LOAD -gt $CPU_LOAD_CRITICAL ]] ; then

if (( $(echo "$CPU_LOAD $CPU_LOAD_CRITICAL" | awk '{print ($1 > $2)}') )) ; then
    PROC=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1`
    echo " >>>> : callling check_alert_count_cpu "
    echo " >>>> : SEND_ALERT_FLAG_CPU : $SEND_ALERT_FLAG_CPU"
    check_alert_count_cpu
    MESSAGE="$(date) - [CRITICAL] [ALERT FIRING] SXP node high CPU usage problem! #count:$COUNTER_CPU - Please check your processess $PROC - Linux SAR total CPU usage: $CPU_LOAD % - hostname=$HOSTNAME"
    echo " >>>> : MESSAGE : $MESSAGE"
    echo " >>>> : SEND_ALERT_FLAG_CPU : $SEND_ALERT_FLAG_CPU"
    discord_send_cpu
else
    if [ -f "$FILE_CPU" ] ; then
        echo "$FILE_CPU exists."
        MESSAGE="$(date) - [INFO] [ALERT RESOLVED] SXP node normal CPU usage again! - Linux SAR total CPU usage: $CPU_LOAD % - hostname=$HOSTNAME"
        rm $FILE_CPU
        SEND_ALERT_FLAG_CPU=true
        echo " >>>> : $MESSAGE"
        discord_send_cpu
    fi
fi
