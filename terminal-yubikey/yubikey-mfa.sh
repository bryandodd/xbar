#!/bin/bash

###############################################################################
# Script Name  : yubikey-mfa.sh
# Description  : Read OATH keys from Yubikey and generate TOTP 
#                codes on-demand
# Version      : v1.0.1
# Dependencies : yubikey-manager (https://github.com/Yubico/yubikey-manager)
# Author       : Bryan Dodd
# Email        : bryan@dodd.dev
# GitHub       : https://github.com/bryandodd/xbar
###############################################################################

# Colors
color_nocolor='\033[0m'
color_yellow2='\033[1;93m'
color_yellow_italic='\033[3;93m'
color_cyan2='\033[1;36m'
redexclaim='\033[1;31m[!!]\033[0m'

ykPasswordRequired=false
ykPasswordString="some-password"
ykUseSerial=false
ykDevice=99999999
ykMaxKeys=64

readYubikeyOath() {
    ykOathList=""
    cmd=("ykman")
    [ "$ykUseSerial" = true ] && cmd+=(--device "$ykDevice")
    cmd+=(oath accounts list)
    [ "$ykPasswordRequired" = true ] && cmd+=(-p "$ykPasswordString")
    ykOathList=$("${cmd[@]}")
    
    ykItemCount=""
    printf "\n${color_cyan2}%3s %-25s %-25s${color_nocolor}\n" "##" " Token Issuer" " Account ID"
    printf "${color_cyan2}%3s %-25s %-25s${color_nocolor}\n" "--" " ------------------------" " ------------------------"
    if [ $? -eq 0 ]; then
        ykItemCount=$(echo "$ykOathList" | wc -l | xargs)
        for (( i=1; i<=$ykItemCount; i++ )); do
            ykItem=$(echo "$ykOathList" | sed -n ${i}p)
            issuer=$(echo "$ykItem" | cut -d':' -f 1)
            acct=$(echo "$ykItem" | cut -d':' -f 2)
            printf "%3s) %-25s %s\n" "$i" "$issuer" "$acct"
        done
    else
        echo "${color_yellow_italic}Error pulling OATH codes from Yubikey.${color_nocolor}"
    fi
}

ykTest=$(ykman list)
ykCount=$(echo "$ykTest" | wc -l)
if [ -z "$ykTest" ]; then
    printf "${color_yellow_italic}Yubikey not detected.${color_nocolor}\n"
    printf "Insert key and try again.\n"
    exit 1
elif [ "$ykCount" -gt 1 ] && [ "$ykUseSerial" = false ]; then
    printf "${color_yellow_italic}Multiple YubiKeys detected.${color_nocolor}\n"
    printf "Specify target device serial number.\n"
    exit 1
fi

if [[ "$#" == "0" ]]; then
    readYubikeyOath
    printf "\n${color_yellow2}Which key? : ${color_nocolor}"
    read opt
    if [[ $opt =~ ^[0-9]+$ ]] && (( (opt >= 1) && (opt <= "${ykItemCount}" ) )); then
        ykSelect=$(echo "$ykOathList" | sed -n ${opt}p)
        printf "\n%s :: %s\n" "$(echo "$ykSelect" | cut -d':' -f 1)" "$(echo "$ykSelect" | cut -d':' -f 2)"
        oathCode=""
        cmd=("ykman")
        [ "$ykUseSerial" = true ] && cmd+=(--device "$ykDevice")
        cmd+=(oath accounts code)
        [ "$ykPasswordRequired" = true ] && cmd+=(-p "$ykPasswordString")
        cmd+=(-s "$ykSelect")
        oathCode=$("${cmd[@]}")
        echo "$oathCode" | pbcopy
        printf "${color_cyan2}->${color_nocolor}  MFA Code: ${color_yellow2}%s ${color_nocolor} ${color_cyan2}<-${color_nocolor}\n" "$oathCode"
    else
        printf "${redexclaim} Invalid selection.\n"
    fi
elif [[ "$#" == "1" ]] && [[ "$1" == "list" ]]; then
    readYubikeyOath
elif [[ "$#" == "1" ]] && [[ "$1" =~ ^[0-9]+$ ]]; then
    opt=$1
    if (( (opt >= 1) && (opt <= $ykMaxKeys) )); then
        ykOathList=""
        cmd=("ykman")
        [ "$ykUseSerial" = true ] && cmd+=(--device "$ykDevice")
        cmd+=(oath accounts list)
        [ "$ykPasswordRequired" = true ] && cmd+=(-p "$ykPasswordString")
        ykOathList=$("${cmd[@]}")
        ykItemCount=$(echo "$ykOathList" | wc -l | xargs)
        if (( (opt > $ykItemCount) )); then
            printf "${redexclaim} Invalid selection. You entered $opt but only $ykItemCount key(s) were found.\n"
            exit 1
        fi
        ykSelect=$(echo "$ykOathList" | sed -n ${opt}p)
        printf "\n%s :: %s\n" "$(echo "$ykSelect" | cut -d':' -f 1)" "$(echo "$ykSelect" | cut -d':' -f 2)"
        oathCode=""
        cmd=("ykman")
        [ "$ykUseSerial" = true ] && cmd+=(--device "$ykDevice")
        cmd+=(oath accounts code)
        [ "$ykPasswordRequired" = true ] && cmd+=(-p "$ykPasswordString")
        cmd+=(-s "$ykSelect")
        oathCode=$("${cmd[@]}")
        echo "$oathCode" | pbcopy
        printf "${color_cyan2}->${color_nocolor}  MFA Code: ${color_yellow2}%s ${color_nocolor} ${color_cyan2}<-${color_nocolor}\n" "$oathCode"
    fi
elif [[ "$#" == "1" ]]; then
    # Attempt to pull a code for the direct input provided.
    ykSelect=$1
    oathCode=""
    cmd=("ykman")
    [ "$ykUseSerial" = true ] && cmd+=(--device "$ykDevice")
    cmd+=(oath accounts code)
    [ "$ykPasswordRequired" = true ] && cmd+=(-p "$ykPasswordString")
    cmd+=(-s "$ykSelect")
    oathCode=$("${cmd[@]}")
    echo "$oathCode" | pbcopy
    echo "$oathCode"
else
    printf "${redexclaim} Syntax error. Check parameter and try again.\n"
fi