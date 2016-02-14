# qubes-setup-vm

Scripts to help setup VMs for [Qubes](https://www.qubes-os.org).


## Rationale

It can be time consuming to setup and tweak VMs for common tasks. Since the
default template VM is the same for all Qubes users, config and setup can
be the same for every user.


## Goals

- Disable misfeatures in Fedora
- Provide automated setup for common or difficult tasks
- Provide more secure setup for untrustworthy/insecure third-party
  apps like Skype and flash
- Automate adjustments to the default template VM for better
  privacy and security
- Experiment with new policies for security and containment
- Play with and learn about Qubes admin tools


## Installation

To start you need to install this repo in your template VM and dom0. Run the
following command from dom0:

```
qvm-run --auto --pass-io sys-firewall 'wget -q https://raw.githubusercontent.com/jgriffiths/qubes-setup-vm/master/initialise.sh -O -' >tmp.sh
bash tmp.sh
```

This will install to `/etc/qubes-setup-vm/` on dom0 and your template VM.


## Available Tasks

### Fedora Misfeatures

- `abrtd` is buggy, constantly updating, instrusive and potentially privacy
violating. It breaks python exception reporting. It breaks KDE drkonqi bug
handling. It forces user interaction where none should be required, it
cannot be properly disabled on a per VM basis once installed, it causes crash
reports to be stored, including memory contents, and its not really intended
for non-Fedora systems like Xen AFAICS. To remove it run the following from
dom0:
```
/etc/qubes-setup-vm/remove_abrtd.sh
```

- `PackageKit` is terrible but cannot be removed because of excessive
dependencies. The parts that can be disabled like the command-not-found
behaviour that causes huge delays when commands are mistyped can be removed
from dom0 by running:
```
/etc/qubes-setup-vm/remove_packagekit.sh
```

### Other tasks

- Setup an [OpenVPN](./vpn/README.md) proxy VM.

- Run [Skype](./skype/README.md) in its own locked down VM.

- Make a [Flash](./flash/README.md) enabled disposable VM.

- Install the [Oracle Java SDK](./oracle_jdk/README.md) to a VM.

- Install the [Android SDK](./android_sdk/README.md) to a VM.
