Overview
--------

Semi-automated setup of Oracles
[Java Development Kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
in a [Qubes](https://www.qubes-os.org) appVM.


## Security Considerations

The JDK is downloaded and installed to `/rw/usrlocal` in its own appVM. It
is never installed into any template VM. This setup brings the same benefits
as listed in the Skype install.


Setup
-----

- You must manually download the Java SE 64 bit JDK RPM file to a VM.
Click the `Download` button under `JDK` on the page linked above, then
click on the rpm file next to `Linux x64`.

- In `dom0`, run `/etc/qubes-setup-vm/oracle_jdk.sh vm_name path_spec`
 - `vm_name` is the name of a new VM to create or existing VM to install to
 - `path_spec` is path to the rpm file as `vm_name:/path/to/file.rpm`

- Reboot the install VM to remove install artifacts from the root filesystem.

- When you log in to the system, JAVA_HOME and PATH should be set so you can
use the compiler etc directly.
