# Legacy MFA via Terminal

![](../images/mfa-terminal.png)

Before I discovered `xbar`, I wrote a small script for my shell profile that provided this functionality from the terminal. It was easily modified for the xbar module, but this method still works well if you cannot install xbar and don't have or can't get a Yubikey. 

* [OATH-Toolkit](https://www.nongnu.org/oath-toolkit/) is required. Install with `brew install oath-toolkit`.
* Save a file on your system named something like `.mfa-codes`. For the sake of example we'll say this is saved at `~/.mfa/.mfa-codes`. This file should contain information structured as follows: 
    ```
    short-name, tab-character, mfa-code, tab-character, username (or email), tab-character, long-description, new-line
    ```

    The contents of the file should look something like this:
    ```
    # TOKENS

    aws-prod	ABC123ABC123ABC1	user@email.com	AWS (Prod)
    aws-dev	ABC123ABC123ABC1	user2@email2.com	AWS (Dev)
    microsoft	ABC123ABC123ABC1	user3@email3.com	O365
    vpn	ABC123ABC123ABC1	user4	Office VPN
    lastpass	ABC123ABC123ABC1	user5@email5.com	LastPass
    gitlab	ABC123ABC123ABC1	user6@email6.com	GitLab (Personal)
    outlook	ABC123ABC123ABC1	user7@outlook.com	Outlook (Personal)
    paypal	ABC123ABC123ABC1	user8@email8.com	PayPal (Personal)
    ```

* Add the following to your shell profile:
    ``` bash
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
    ```
