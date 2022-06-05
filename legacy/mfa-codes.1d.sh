#!/bin/bash
# <xbar.title>MFA Codes On-Demand</xbar.title>
# <xbar.version>v1.1.0</xbar.version>
# <xbar.author>Bryan Dodd</xbar.author>
# <xbar.author.github>bryandodd</xbar.author.github>
# <xbar.desc>Displays MFA codes determined from in-file TOTP keys. Refreshes daily by default.</xbar.desc>
# <xbar.dependencies>bash, oathtool</xbar.dependencies>
# <xbar.image> </xbar.image>

# Dependencies:
#   OATH-Toolkit (https://www.nongnu.org/oath-toolkit/)
#       brew install oath-toolkit

# Settings:
# 1. ENABLE_DEFAULT_CODE will cause your default MFA token to be displayed in the menu bar.
#    Disabled by default.
# 2. ENABLE_DEFAULT_COPY, only used when ENABLE_DEFAULT_CODE is also true, will cause a 
#    "Copy Default Code" option to appear in the menu.
# 3. ONLY_ONE_GROUP changes the format of the output to a single list, ignoring group2 or any
#    other groups that have been added to the script.
# 4. ENABLE_SUBMENU causes MFA codes to roll-up to their group heading. Codes are nested in
#    a submenu and displayed by group rather than together with all codes from all groups. 

# Other Notes:
# *  Tested and works well with Nerd Fonts. My preference is JetBrains Mono Nerd Font but this
#    can easily be changed to your own preference.
# 
# *  If you wish to ENABLE the default code, consider changing the script name to execute every 
#    five (5) or fewer seconds. By default, the script will not display a default code and therefore
#    refreshes only once per day.
#
# *  Add your MFA codes to the variables below, taking care to separate the text label from the 
#    code value with a COLON (:). 

ENABLE_DEFAULT_CODE=false
ENABLE_DEFAULT_COPY=true
ONLY_ONE_GROUP=false
ENABLE_SUBMENU=false

FONT=( "size=13 font='JetBrainsMonoNerdFontComplete-Regular'" )
LABELFONT=( "size=14 font='JetBrainsMonoNerdFontComplete-Bold-Italic'" )

PATH=/usr/local/bin:/usr/bin

DEFAULT_NAME=""
DEFAULT_KEY="ABC123ABC123ABC1"
MenuCode=$(oathtool -b --totp $DEFAULT_KEY)

if [ "$1" = 'copyDefault' ]; then
    echo "$MenuCode" | pbcopy
fi

if [ "$1" = 'copyCode' ]; then
    oathtool -b --totp $2 | pbcopy
fi

# mfa codes - group 1
group1Name=" Work Codes"
group1Color="blue"
mfaGroup1=(
    "AWS:ABC123ABC123ABC1"
    "O365:ABC123ABC123ABC1"
    "VPN:ABC123ABC123ABC1"
    "Intranet:ABC123ABC123ABC1"
    "LastPass:ABC123ABC123ABC1"
)

# mfa codes - group 2
group2Name=" Personal Codes"
group2Color="yellow"
mfaGroup2=(
    "AWS:ABC123ABC123ABC1"
    "AWS (Root):ABC123ABC123ABC1"
    "Synology:ABC123ABC123ABC1"
    "GitLab:ABC123ABC123ABC1"
    "Outlook:ABC123ABC123ABC1"
    "PayPal:ABC123ABC123ABC1"
)

# xbar start
if [ "$ENABLE_DEFAULT_CODE" = true ]
then
    echo "$DEFAULT_NAME $MenuCode | $FONT"
else
    echo "MFA Tokens"
fi
echo "---"

if [ "$ENABLE_DEFAULT_COPY" = true ] && [ "$ENABLE_DEFAULT_CODE" = true ]
then
    echo "Copy Default Code | bash='$0' param1=copyDefault terminal=false"
    echo "---"
fi

if [ "$ONLY_ONE_GROUP" = false ]; then echo "$group1Name | $LABELFONT color=$group1Color"; fi;
for mfa in "${mfaGroup1[@]}"
do
    KEY=${mfa%:*};
    VAL=${mfa#*:};
    if [ "$ENABLE_SUBMENU" = true ]; then KEY="-- $KEY"; fi;
    echo "$KEY | $FONT bash='$0' param1=copyCode param2=$VAL terminal=false"
done

if [ "$ONLY_ONE_GROUP" = false ]
then
    echo "---"
    echo "$group2Name | $LABELFONT color=$group2Color"
    for mfa in "${mfaGroup2[@]}"
    do
        KEY=${mfa%:*};
        VAL=${mfa#*:};
        if [ "$ENABLE_SUBMENU" = true ]; then KEY="-- $KEY"; fi;
        echo "$KEY | $FONT bash='$0' param1=copyCode param2=$VAL terminal=false"
    done
fi

echo "---"
