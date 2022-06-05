#!/bin/bash

###############################################################################
# Script Name  : legacy-mfa.sh
# Description  : Read OATH keys from static file and generate TOTP 
#                codes on-demand
# Version      : v0.1.0
# Dependencies : OATH-Toolkit (https://www.nongnu.org/oath-toolkit/)
# Author       : Bryan Dodd
# Email        : bryan@dodd.dev
# GitHub       : https://github.com/bryandodd/xbar
###############################################################################

color_nocolor='\033[0m'
color_yellow2='\033[1;93m'
color_yellow_italic='\033[3;93m'
color_cyan2='\033[1;36m'

alias mfa="getMfaToken "

getMfaToken() {
    tSource="$HOME/.mfa/.mfa-codes"

    if [[ "$1" == "list" ]]
    then
        awk -F\t '{printf("%-25s %-25s \n",$1,$4)}' $tSource
    else
        tString=$(grep "^$1\\t" "$tSource")

        if [ $? -eq 0 ]
        then
            tUser="$(echo $tString | awk -F\t '{print $3}')"
            tCode="$(echo $tString | awk -F\t '{print $2}')"
            tDesc="$(echo $tString | awk -F\t '{print $4}')"
            echo " "
            echo "$tDesc :: $tUser"
            tValue=$(oathtool -b --totp $tCode)
            echo -e "${color_cyan2}->${color_nocolor}  MFA Code: ${color_yellow2}$tValue ${color_nocolor} ${color_cyan2}<-${color_nocolor}"
            echo " "
            echo "$tValue" | pbcopy
        else
            echo "${color_yellow_italic}Code not found.${color_nocolor}"
        fi
    fi
}
