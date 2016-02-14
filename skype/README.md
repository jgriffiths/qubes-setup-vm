# Overview

Semi-automated setup of [Skype](www.skype.com) in a [Qubes](https://www.qubes-os.org)
appVM, under [firejail](https://firejail.wordpress.com) if available.

## Security Considerations

Skype is downloaded and installed to `/rw/usrlocal` in its own appVM. It is never
installed into any template VM (although its dependencies are). This setup means:

- Only the Skype appVM ever runs the rpm install.
- Only the Skype appVM ever contains the Skype binaries.
- Only the Skype appVM needs to have the microphone attached/detached.
- The netVM of the Skype appVM can be used to route/filter all of its traffic
  independently of other VMs/apps.
- No user data is accessible to Skype except that which it wrote itself
  and that which can be gleaned from the appVM.
- If firejail is available then Skype is limited even further using firejails'
  built-in Skype profile. For example, the only directory it can read from is
  the VMs home directory is `.Skype`.


## Setup

- Optionally, install firejail in your default templateVM (This cannot be
easily automated yet).

- In `dom0`, run `/etc/qubes-setup-vm/skype.sh [vm_name]`

- You can now run the Skype VM from dom0 using `~/skype/skype.sh`, or add
this script to the Q menu along with skypes icon `~/skype/skype.png`.

