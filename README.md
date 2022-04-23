# xbar modules

This repository contains [xbar](https://github.com/matryer/xbar) modules. Scripts are self-documenting so please read carefully before making modifications. 

## Modules

### `mfa-codes.5s.sh`
``` bash
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
```
