# Yubikey MFA for macOS

## `mfa-yubikey.1d.sh`

![](../images/yubikey-2.png)  ![](../images/yubikey-1.png) 

### Dependencies
* [yubikey-manager](https://github.com/Yubico/yubikey-manager) - `brew install ykman`

### Operational Settings
| Setting | Default | Note |
| ------- | ------- | ---- |
| `ykPassRequired` | `false` | Change to `true` if your Yubikey has been configured to require a password for OATH use. When `true`, `ykPassword` must also be supplied for proper operation. |
| `ykPassword` | `YUBIKEY-OATH-PASSWORD` | Required when `ykPassRequired` is `true`. This value is a plain-text string of your Yubikey OATH password. |
| `ykOrderOverride` | `false` | OATH codes are read from Yubikey and displayed in alphabetical order. To override this behavior, or to selectively group or omit codes, set value to `true`. When set to `true`, you must provide *(at minimum)* the values for all three `groupPrimary` settings (identified below). |
| `ykUseSerial` | `false` | Change to `true` to directly target a specific Yubikey if you have (or expect to have) multiple Yubikeys connected to your machine at one time. When `true`, `ykDevice` must also be supplied for proper operation. |
| `ykDevice` | `99999999` | Required when `ykUseSerial` is `true`. The Serial Number of the Yubikey you want the module to read from. |
| `iconEnable` | `true` | Designed to be used in conjunction with [Nerd Fonts](https://www.nerdfonts.com/). If set to `true`, values specified in the `iconArray` will be used to "look up" which Nerd Font glyphs should be used with each OATH code from the Yubikey. |
| `groupSecondaryEnable` | `true` | Enable support for grouping Yubikey OATH keys in two groups. |
| `submenuEnable` | `false` | Enable nesting of OATH keys under their group name. Causes only one group of keys to be visible at a time. |

### Configuration Settings
| Setting | Note |
| ------- | ---- |
| `ykOathList` | Intentionally empty. Do not modify. |
| `groupPrimaryName` / `groupSecondaryName` | Heading name for groups of OATH codes. |
| `groupPrimaryColor` / `groupSecondaryColor` | Heading colors for groups of OATH codes. When `submenuEnable` is true, headings become interactive and the colors become darker. Using the IF statement, manually specify a lighter color for submenus to keep colors consistent between modes.<br />`$(if [ "$submenuEnable" = "true" ]; then echo "#807FFE"; else echo "BLUE"; fi;)` |
| `groupPrimaryList` / `groupSecondaryList` | Array of OATH keys. The format must match the output from Yubikey. To see which keys are available on your device, run `ykman oath accounts list`. Values must be contained within double-quotes and do not separate with commas (`,`). |
| `iconArray` | Used only if `iconEnable` is `true`. Array of labels paired with Nerd Font glyphs. Separate key/value with a colon (`:`), use double quotes (`"`), and do not separate value pairs with commas (`,`). If an OATH key is found that does not have a matching glyph, a circle and exclaimation glyph will display for that OATH entry. |

### Notes
* Tested with Nerd Fonts. My preference is `JetBrains Mono Nerd Font Propo`, but this can easily be changed to your liking. The "propo" fonts by [NerdFonts](https://www.nerdfonts.com/) proportionalize the icons for a more pleasing arrangement for UI purposes. See the `FONT` variable.
* If your Yubikey is not inserted when the `xbar` application loads, or if your key is not detected for any other reason, you may see a "Yubikey not detected" message. Insert your Yubikey and click the "reload" option to refresh the extension and read OATH codes from your device.
* Tested and working with Yubikey OATH codes regardless of "touch" setting. If your code has been configured to require touch, no additional prompts will display on-screen, but your Yubikey will begin to flash after clicking the name of the code you with you retrieve. Tap your key as usual and the value will be recorded to the macOS clipboard.

### Changes

#### [1.0.4] - 2025-02-09

##### Added

* Support for multiple device handling and enabling selection of specific keys by serial number (`ykUseSerial` and `ykDevice`).

##### Changed

* Cleaned up notes/comments in the first several lines of the file.
* Moved `ykOathList` variable to more appropriate location. *(Not intended for user modification.)*
* Moved `groupSecondaryEnable` up to the list of commonly updated parameters for better visibility.
* Revised the "on-click" action and "get list" operations to be dynamically constructed vs using conditional logic.
* Removed `submenuEnable` references from sections of the script where it will never be executed.

#### [1.0.3] - 2025-02-02

##### Changed

* The *shebang* has been changed from `#!/bin/bash` to `#!/usr/bin/env bash`.
* The previous version included poor handling for the `PATH` variable. The current version has checks to determine if it is running on Apple Silicon and sets the Homebrew path accordingly.
