# Overview

Semi-automated setup of [Adobe Flash](https://www.adobe.com/products/flashplayer.html)
under [Firefox](https://www.mozilla.org/en-US/firefox/desktop/) in
a [Qubes](https://www.qubes-os.org) disposable VM.


## Security Considerations

Flash is downloaded from the official repo and the rpm file is stored
in the home directory of the disposable VM template. It is never installed
into any template VM, including the disposable VM template. This setup means:

- Only the disposable VM you start to run flash ever installs it.
- All other disposable VMs do not have flash installed or available.
- All changes due to flash (cached files, malware etc) are destroyed when
  the disp VM exits (assuming no VM escape).
- No user data is accessible to flash except that which it wrote itself
  and that which can be gleaned from the disposible VM.

WARNING: You should ensure that your disposable VM template does not
contain sensitive data in the user home directory.


## TODO

1. Run firefox + flash under firejail.

2. Check for updates to flash and warn if it has been updated, since any
   updates are probably going to be security fixes.


## Setup

- In `dom0`, run `/etc/qubes-setup-vm/flash.sh`

- Run firefox with flash in a dispVM from dom0 using `~/firefox-flash.sh`
