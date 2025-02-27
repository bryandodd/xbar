#!/usr/bin/env bash
# <xbar.title>YubiKey MFA</xbar.title>
# <xbar.version>v1.0.4</xbar.version>
# <xbar.author>Bryan Dodd</xbar.author>
# <xbar.author.github>bryandodd</xbar.author.github>
# <xbar.desc>Decode TOTP codes from YubiKey OATH. Refreshes daily by default.</xbar.desc>
# <xbar.dependencies>bash,ykman</xbar.dependencies>
# <xbar.image>https://github.com/bryandodd/xbar/raw/main/images/yubikey-2.png</xbar.image>
# <xbar.abouturl>https://github.com/bryandodd/xbar/tree/main/yubikey-support</xbar.abouturl>

# Dependencies:
#   yubikey-manager (https://github.com/Yubico/yubikey-manager)
#       brew install ykman

# Settings:
# 1. If your YubiKey has been configured to require a password for OATH use, change "ykPassRequired"
#    to TRUE. If set to TRUE, "ykPassword" must also be supplied for proper operation. 
#
# 2. If "ykPassRequired" was set to TRUE, set "ykPassword" to the plain-text string of your password.
#    Note -- If you change the single-apostrophe to double-apostrophe, you must ESCAPE your string.
#            For example, if your password contains a "!" character, you must escape it with "\!"
#
# 3. By default, keys are read directly from YubiKey and output in alphabetical order (such is YubiKey's
#    default). If you prefer to override the order, display only select codes, or group codes into
#    categories, set "ykOrderOverride" to TRUE. When set to TRUE, you must supply at minimum
#    "groupPrimaryList", but see the seven (7) "group" variables below:
#
#        * groupPrimaryName:     Category name, used only if "groupSecondaryEnable" is TRUE.
#        * groupPrimaryColor:    Category name display color.
#        * groupPrimaryList:     List of codes you wish to have made available. The format should be exactly
#                                the same as the output from running: "ykman oath accounts list"
#                                It should appear as ISSUER:ACCOUNT. Do not separate array entries with commas.
#
#        * groupSecondaryEnable: Enables multi-group support for manual override. (Split codes into two groups)
#        * groupSecondaryName:   Category name, used only if "groupSecondaryEnable" is TRUE.
#        * groupSecondaryColor:  Category name display color.
#        * groupSecondaryList:   See explanation of "groupPrimaryList" above.
#
# 4. If you might have multiple YubiKeys connected at some point, change "ykUseSerial" to TRUE. When set to
#    TRUE, "ykDevice" must also be set to the correct Serial Number of your target YubiKey. 
#
# 5. If "ykUseSerial" was set to TRUE, enter the YubiKey Serial Number of the device containing the OATH
#    codes you wish to use. 
#
# 6. To use Nerd Font glyphs in conjunction with OATH key names, set "iconEnable" to TRUE. When enabled,
#    values specified in the `iconArray` will be used to "look up" which glyphs should be used with each OATH 
#    code from the YubiKey.
#
# 7. When "ykOrderOverride" is TRUE, "groupSecondaryEnable" enables splitting codes between two different groups
#    or categories (i.e., "Work" and "Personal"). By default, both groups will be displayed on-screen simultaneously.
#    Set "submenuEnable" (below) to TRUE to nest OATH codes under their group name and cause only one group of codes
#    to be visible at once. 
#
# 8. When "groupSecondaryEnable" is TRUE, "submenuEnable" can be set to TRUE to enable nesting of codes under 
#    their group names instead of having them displayed on-screen at the same time.  
#    See #3 above ('groupPrimary' vs 'groupSecondary') for more information. 

# Other Notes and Comments:
# *  Tested and works well with Nerd Fonts. My preference is 'JetBrains Mono Nerd Font' but this
#    can easily be changed to your own liking. See "FONT" variable below.
#
# *  Tested and works well with YubiKey OATH codes regardless of their "touch" setting. If your code
#    has been configured to require touch, no additional prompts will display on-screen, but your
#    YubiKey will begin to flash after clicking the name of the code you wish to retreive. Tap your
#    key as usual and the value will be recorded to the macOS clipboard. 
# 
# *  If dependencies are not being located correctly, check the "PATH" variable. This script looks at 
#    '/opt/homebrew/' for Apple Silicon devices, or '/usr/local/' for Intel. For non-standard configurations,
#    you may need to adjust the PATH.

ykPassRequired=false
ykPassword='YUBIKEY-OATH-PASSWORD'
ykOrderOverride=false
ykUseSerial=false
ykDevice=99999999
iconEnable=true
groupSecondaryEnable=true
submenuEnable=false

FONT=( "size=13 font='JetBrainsMonoNFP-Regular'" )
LABELFONT=( "size=14 font='JetBrainsMonoNFP-BoldItalic'" )

# update PATH for Apple Silicon
if [[ $(uname -m) == 'arm64' ]]
then
    PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
else
    PATH="/usr/local/sbin:$PATH"
fi

# Optional: manually control ordering / grouping of codes
groupPrimaryName=" Work Codes"
groupPrimaryColor=$(if [ "$submenuEnable" = "true" ]; then echo "#807FFE"; else echo "BLUE"; fi;)
groupPrimaryList=(
    "AWS [Prod]:usera@example.com"
    "O365:usera@example.com"
    "VPN:usera"
    "LastPass:useralpha"
)

groupSecondaryName=" Personal Codes"
groupSecondaryColor=$(if [ "$submenuEnable" = "true" ]; then echo "#FFFF80"; else echo "YELLOW"; fi;)
groupSecondaryList=(
    "AWS [Personal]:usera@email.com"
    "Synology:usera@email.com"
    "GitHub:useralpha"
    "Outlook:usera@email.com"
)

iconArray=(
    "AWS:"
    "O365:"
    "LastPass:聾"
    "VPN:嬨"
    "Synology:"
    "GitHub:"
    "Outlook:"
)

## Don't edit below this line unless you know what you're doing 
## or have at least made a backup before experimenting. :) 

# on-click action - copy to macOS clipboard
if [ "$1" = 'copyCode' ]; then
    # ykman --device "$ykDevice" oath accounts code -p "$ykPassword" -s "$2"
    cmd=("ykman")
    [ "$ykUseSerial" = true ] && cmd+=(--device "$ykDevice")
    cmd+=(oath accounts code)
    [ "$ykPassRequired" = true ] && cmd+=(-p "$ykPassword")
    cmd+=(-s "$2")
    "${cmd[@]}" | pbcopy
fi

# get list from yubikey if not manually specifying
ykOathList=""
if [ "$ykOrderOverride" = false ]; then
    # ykman --device "$ykDevice" oath accounts list -p "$ykPassword"
    cmd=("ykman")
    [ "$ykUseSerial" = true ] && cmd+=(--device "$ykDevice")
    cmd+=(oath accounts list)
    [ "$ykPassRequired" = true ] && cmd+=(-p "$ykPassword")
    ykOathList=$("${cmd[@]}")
fi

# xbar start
echo "YubiKey MFA"
echo "---"

ykTest=$(ykman list)
ykCount=$(echo "$ykTest" | wc -l)
if [ -z "$ykTest" ]
then
    echo "YubiKey not detected."
    echo "Insert key and click to reload.| terminal=false refresh=true"
elif [ "$ykCount" -gt 1 ] && [ "$ykUseSerial" = false ]
then
    echo "Multiple YubiKeys detected."
    echo "Specify target device serial number and click to reload.| terminal=false refresh=true"
else
    if [ "$ykOrderOverride" = false ]
    then
        echo "$ykOathList" | while read line ; do
            ykOathItem=$line
            issuer=$(echo $ykOathItem | cut -d':' -f 1)
            if [ "$iconEnable" = true ]
            then
                iconFound=false
                for iconSet in "${iconArray[@]}"; do
                    searchTerm="${iconSet%%:*}"
                    icon="${iconSet##*:}"                    
                    if [[ "$issuer" == *"$searchTerm"* ]]; then
                        echo "$icon $issuer| $FONT bash='$0' param1=copyCode param2='$ykOathItem' terminal=false"
                        iconFound=true
                    fi
                done
                nest=""
                if [ "$iconFound" = false ]; then echo "${nest} $issuer| $FONT bash='$0' param1=copyCode param2='$ykOathItem' terminal=false"; fi
            else
                echo "$issuer| $FONT bash='$0' param1=copyCode param2='$ykOathItem' terminal=false"
            fi
        done
    else
        if [ "$groupSecondaryEnable" = true ]; then echo "$groupPrimaryName | $LABELFONT color=$groupPrimaryColor"; fi;
        for ykItem in "${groupPrimaryList[@]}"
        do
            issuer=$(echo $ykItem | cut -d':' -f 1)
            if [ "$iconEnable" = true ]
            then
                iconFound=false
                for iconSet in "${iconArray[@]}"; do
                    searchTerm="${iconSet%%:*}"
                    icon="${iconSet##*:}"
                    if [[ "$issuer" == *"$searchTerm"* ]]; then
                        if [ "$submenuEnable" = true ]; then icon="-- $icon"; fi;
                        echo "$icon $issuer| $FONT bash='$0' param1=copyCode param2='$ykItem' terminal=false"
                        iconFound=true
                    fi
                done
                nest=""
                if [ "$submenuEnable" = true ]; then nest="--"; fi;
                if [ "$iconFound" = false ]; then echo "${nest} $issuer| $FONT bash='$0' param1=copyCode param2='$ykItem' terminal=false"; fi
            else
                if [ "$submenuEnable" = true ]; then issuer="-- $issuer"; fi;
                echo "$issuer| $FONT bash='$0' param1=copyCode param2='$ykItem' terminal=false"
            fi
        done

        if [ "$groupSecondaryEnable" = true ]
        then
            echo "---"
            echo "$groupSecondaryName | $LABELFONT color=$groupSecondaryColor"
            for ykItem in "${groupSecondaryList[@]}"
            do
                issuer=$(echo $ykItem | cut -d':' -f 1)
                if [ "$iconEnable" = true ]
                then
                    iconFound=false
                    for iconSet in "${iconArray[@]}"; do
                        searchTerm="${iconSet%%:*}"
                        icon="${iconSet##*:}"
                        if [[ "$issuer" == *"$searchTerm"* ]]; then
                            if [ "$submenuEnable" = true ]; then icon="-- $icon"; fi;
                            echo "$icon $issuer| $FONT bash='$0' param1=copyCode param2='$ykItem' terminal=false"
                            iconFound=true
                        fi
                    done
                    nest=""
                    if [ "$submenuEnable" = true ]; then nest="--"; fi;
                    if [ "$iconFound" = false ]; then echo "${nest} $issuer| $FONT bash='$0' param1=copyCode param2='$ykItem' terminal=false"; fi
                else
                    if [ "$submenuEnable" = true ]; then issuer="-- $issuer"; fi;
                    echo "$issuer| $FONT bash='$0' param1=copyCode param2='$ykItem' terminal=false"
                fi
            done
        fi
    fi
fi

echo "---"