#!/bin/bash
# <xbar.title>MFA Codes On-Demand</xbar.title>
# <xbar.version>v1.1</xbar.version>
# <xbar.author>Bryan Dodd</xbar.author>
# <xbar.author.github>bryandodd</xbar.author.github>
# <xbar.desc>Displays MFA codes. Updates every 5 seconds.</xbar.desc>
# <xbar.dependencies>bash, oathtool</xbar.dependencies>
# <xbar.image> </xbar.image>

# Dependencies:
#   OATH-Toolkit (https://www.nongnu.org/oath-toolkit/)
#       brew install oath-toolkit

# Settings:
# 1. ENABLE_DEFAULT_CODE will cause your default MFA token to be displayed in the menu bar.
# 2. ENABLE_DEFAULT_COPY, if ENABLE_DEFAULT_CODE is ALSO true, will cause a "Copy Default Code" 
#    option to appear in the menu.
# 3. ONLY_ONE_GROUP changes the format of the output to a single list, ignoring group2 or any
#    other groups that have been added to the script.

# Other Notes:
# *  Tested and works well with Nerd Fonts. My preference is JetBrains Mono Nerd Font but this
#    can easily be changed to your own preference (https://www.nerdfonts.com/font-downloads)
# 
# *  If you wish to DISABLE the default code, consider changing the script name to only execute
#    every 1 day (1d). By default, the script assumes you will be displaying a default code and
#    therefore refreshes every 5 seconds (5s).
#
# *  Add your MFA codes to the variables below, taking care to separate the text label from the 
#    code value with a COLON (:). Separate each code on a new line and do not use COMMAS (,).

ENABLE_DEFAULT_CODE=true
ENABLE_DEFAULT_COPY=true
ONLY_ONE_GROUP=false

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
        echo "$KEY | $FONT bash='$0' param1=copyCode param2=$VAL terminal=false"
    done
fi

echo "---"
