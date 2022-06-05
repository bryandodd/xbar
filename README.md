# xbar modules

This repository contains [xbar](https://github.com/matryer/xbar) modules. I've attempted to make scripts self-documenting, so please read carefully before making modifications. 

Originally, this project started as a way for me to manage a growing list of MFA codes without having to resort to fumbling around with my phone every 5 minutes. One very important take-away from this project is that the legacy mode of operation is infinitely less secure than the Yubikey supported mode. 

Only you can make the decision about the level of security you require, but I strongly encourage you to move away from the legacy versions of this tool in favor of the newer Yubikey mode of operation. 

_HOWEVER_, it is still up to you to ensure that your Yubikey is configured properly and securely, and that it is handled in a secure way. Yubikeys are a great value for the cost when weighed against the benefits gained in terms of security.

**Yubikey xbar module**: _(see `./yubikey-support`)_
* [Yubikey MFA for macOS](./yubikey-support/README.md)
    * Current Version: `v1.0.2`

**Legacy xbar module**: _(see `./legacy`)_
* [Legacy MFA for macOS](./legacy/README.md)
    * Current Version: `v1.1.0`

**Terminal**: _(see `./terminal`)_
* [Yubikey MFA via Termianl](./terminal-yubikey/README.md)
    * Current Version: `v1.0.0`
* [Legacy MFA via Terminal](./terminal-legacy/README.md)
    * Current Version: `v0.1.0`

