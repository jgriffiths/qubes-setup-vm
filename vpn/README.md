Overview
--------

Semi-automated setup of an [openvpn](https://openvpn.net/) VPN in a
[Qubes](https://www.qubes-os.org) proxyVM without NetworkManager.


Credit
-------

This setup is only slightly changed from that described by 'cprise' on the
qubes-users thread [here](https://groups.google.com/forum/#!msg/qubes-users/-9gR1Va3BnY/FlKLzdOxJJkJ).
The combined up/down script from Olivier Médoc in that thread is included
and modified to support restarts (SIGUSR1, ping timeouts etc). The use of
a service to restart the VPN after a suspend comes from user 'Cube'. The dom0
VM creation and installation scripts are my own work.

If you would like to be credited explicitly, listed as a copyright
holder, or if you find any bugs, please raise an issue through github
or let me know at jon_p_griffiths@yahoo.com.


Setup
-----

- In `dom0`, run `/etc/qubes-setup-vm/vpn.sh [vm_name]`

- Copy your openvpn config file to `/rw/config/vpn.conf` in the vpn VM and
edit it as needed.  You may need to copy your certs etc to `/rw/config/` and
change any paths in your config file that reference them.

- Make sure you remove any existing lines in `vpn.conf` starting with
`script-security`, `up`, `down`, `up-restart` or `persist-tun`.

- Make sure that if `vpn.conf` includes the `resolv-retry` option that it
is not set to `infinite`. This setting will prevent openvpn from re-resolving
the servers name if the VPN drops, since openvpn needs to restart to allow
resolv.conf to be restored by our up/down script.

- Reboot the vpn VM. You should find that it connects automatically and you
can now set it as the net VM for other appVMs.
