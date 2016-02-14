#!/bin/bash

# From https://groups.google.com/forum/#!msg/qubes-users/-9gR1Va3BnY/FlKLzdOxJJkJ

UNPRIVILEGED_USER=openvpn
SPID=$(pgrep -U user -f dconf-service)
dbus=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$SPID/environ|cut -d= -f2-)
export DBUS_SESSION_BUS_ADDRESS=$dbus


vpn_up()
{
    # Parses DHCP options from openvpn to update resolv.conf
    # To use set as 'up' and 'down' script in your openvpn *.conf:
    # up /etc/openvpn/update-resolv-conf
    # down /etc/openvpn/update-resolv-conf
    #
    # Used snippets of resolvconf script by Thomas Hood <jdthood@yahoo.co.uk>
    # and Chris Hanson
    # Licensed under the GNU GPL.  See /usr/share/common-licenses/GPL.
    # 07/2013 colin@daedrum.net Fixed intet name
    # 05/2006 chlauber@bnc.ch
    #
    # Example envs set from openvpn:
    # foreign_option_1='dhcp-option DNS 193.43.27.132'
    # foreign_option_2='dhcp-option DNS 193.43.27.133'
    # foreign_option_3='dhcp-option DOMAIN be.bnc.ch'
    # foreign_option_4='dhcp-option DOMAIN-SEARCH bnc.local'

    # Retrieve DNS related foreign DHCP variable
    for optionname in ${!foreign_option_*} ; do
        option="${!optionname}"
        echo "Parsing DHCP option: $option"
        part1=$(echo "$option" | cut -d " " -f 1)
        if [ "$part1" == "dhcp-option" ] ; then
            part2=$(echo "$option" | cut -d " " -f 2)
            part3=$(echo "$option" | cut -d " " -f 3)
            if [ "$part2" == "DNS" ] ; then
                IF_DNS_NAMESERVERS="$IF_DNS_NAMESERVERS $part3"
            elif [[ "$part2" == "DOMAIN" || "$part2" == "DOMAIN-SEARCH" ]] ; then
                IF_DNS_SEARCH="$IF_DNS_SEARCH $part3"
            fi
        fi
    done

    # Create new resolv.conf content
    if [[ -n "$IF_DNS_SEARCH" || -n "$IF_DNS_NAMESERVERS" ]] ; then
        # Backup resolv.conf
        cp /etc/resolv.conf /etc/resolv.conf.qubes
        if [ -n "$UNPRIVILEGED_USER" ] ; then
            sudo chown "$UNPRIVILEGED_USER" /etc/resolv.conf.qubes
            sudo chown "$UNPRIVILEGED_USER" /etc/resolv.conf
        fi

        # Clear resolv.conf
        echo -n "" > /etc/resolv.conf

        if [ "$IF_DNS_SEARCH" ]; then
            R="search "
            for DS in $IF_DNS_SEARCH ; do
                R="${R} $DS"
            done
            echo "$R" >> /etc/resolv.conf
        fi

        for NS in $IF_DNS_NAMESERVERS ; do
            R="nameserver $NS"
            echo "$R" >> /etc/resolv.conf
        done

        # Reinit Qubes DNS nat rules
        /etc/dhclient.d/qubes-setup-dnat-to-ns.sh

    fi

    su -c 'notify-send -i /usr/share/pixmaps/faces/tennis-ball.png "VPN IS UP"' user
}


vpn_down()
{
    # Restore our old resolv.conf
    [[ -f /etc/resolv.conf.qubes  ]] && mv -f /etc/resolv.conf.qubes /etc/resolv.conf

    # Reinit Qubes DNS nat rules
    /etc/dhclient.d/qubes-setup-dnat-to-ns.sh

    su -c 'notify-send -i /usr/share/pixmaps/faces/lightning.jpg "VPN IS DOWN !" --icon=dialog-error' user
}


case $script_type in
    up)
        vpn_up
        ;;
    down)
        vpn_down
        ;;
    restart)
        vpn_down
        vpn_up
        ;;
esac
