Overview
--------

Semi-automated setup of Googles
[Android SDK](https://developer.android.com/sdk/index.html)
in a [Qubes](https://www.qubes-os.org) appVM.


## Security Considerations

The SDK is downloaded and installed to the users home directory in its own
appVM. It is never installed into any template VM. This setup brings the
same benefits as listed in the Skype install.


Setup
-----

- You must have previously installed the Oracle JDK to the VM.

- You must manually download the SDK tarball file to a VM.
Click the `android-*-linux.tgz` under `SDK Tools Only' on the page linked
above to download.

- In `dom0`, run `/etc/qubes-setup-vm/android_sdk.sh vm_name path_spec [install_dir]`
 - `vm_name` is the name of a new VM to create or existing VM to install to
 - `path_spec` is path to the tarball file as `vm_name:/path/to/file.tgz`
 - `install_dir` is the desired install path e.g. `/home/user/AndroidSDK`

- When you log in to the system, your PATH should be set so you can run
the android tools directly.
