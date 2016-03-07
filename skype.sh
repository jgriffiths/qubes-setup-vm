#!/bin/bash

install_vm=${1:-skype}
template_vm=$(qubes-prefs --get default-template)
net_vm=$(qvm-prefs -g $template_vm netvm)

.  /etc/qubes-setup-vm/setup/dom0_functions.sh

# Install deps in template VM
qvm-run --auto --pass-io $template_vm 'sudo dnf install -y pavucontrol alsa-lib.i686 alsa-plugins-pulseaudio.i686 audit-libs.i686 bzip2-libs.i686 cairo.i686 cdparanoia-libs.i686 clucene09-core.i686 cracklib.i686 dbus-libs.i686 elfutils-libelf.i686 elfutils-libs.i686 expat.i686 flac-libs.i686 fontconfig.i686 freetype.i686 glib2.i686 glibc.i686 graphite2.i686 gsm.i686 gstreamer1.i686 gstreamer1-plugins-base harfbuzz.i686 jbigkit-libs.i686 json-c.i686 keyutils-libs.i686 krb5-libs.i686 lcms2.i686 libacl.i686 libasyncns.i686 libattr.i686 libcap.i686 libcom_err.i686 libdatrie.i686 libdb.i686 libdrm.i686 libffi.i686 libgcc.i686 libgcrypt.i686 libgpg-error.i686 libICE.i686 libidn.i686 libjpeg-turbo.i686 libmng.i686 libogg.i686 libpciaccess.i686 libpng.i686 libseccomp.i686 libselinux.i686 libSM.i686 libsndfile.i686 libstdc++.i686 libthai.i686 libtheora.i686 libtiff.i686 libuuid.i686 libverto.i686 libvisual.i686 libvorbis.i686 libwayland-client.i686 libwayland-server.i686 libwebp.i686 libX11.i686 libXau.i686 libxcb.i686 libXcursor.i686 libXdamage.i686 libXext.i686 libXfixes.i686 libXft.i686 libXi.i686 libXinerama.i686 libxml2.i686 libXrandr.i686 libXrender.i686 libXScrnSaver.i686 libxshmfence.i686 libxslt.i686 libXtst.i686 libXv.i686 libXxf86vm.i686 mesa-libEGL.i686 mesa-libgbm.i686 mesa-libglapi.i686 mesa-libGL.i686 ncurses-libs.i686 nss-softokn-freebl.i686 openssl-libs.i686 orc.i686 pam.i686 pango.i686 pcre.i686 pixman.i686 proj.i686 pulseaudio-libs.i686 qt.i686 qt-mobility-common.i686 qt-mobility-location.i686 qt-mobility-sensors.i686 qtwebkit.i686 qt-x11.i686 readline.i686 sqlite.i686 systemd-libs.i686 tcp_wrappers-libs.i686 xz-libs.i686 zlib.i686 libXScrnSaver.x86_64 nss-softokn-freebl.x86_64 proj.x86_64 qt-mobility-common.x86_64 qt-mobility-location.x86_64 qt-mobility-sensors.x86_64 qtwebkit.x86_64'

# Shutdown template VM so new VMs get freshly updated packages
qvm-shutdown --wait $template_vm

if vm_create $install_vm $template_vm $net_vm; then
    vm_less_logging $install_vm
    vm_minimum_services $install_vm
else
    qvm-shutdown --wait $install_vm
fi

# Install Skype into skype VM
qvm-run --auto --pass-io $install_vm 'sudo /etc/qubes-setup-vm/skype/install.sh'

# Symlink Skype share directory on VM startup
vm_add_to_rc_local $install_vm 'sudo ln -f -s /rw/usrlocal/share/skype/ /usr/share/skype'

# Fetch Skype icon and create a script to run Skype
# FIXME: Strictly speaking we shouldn't trust the icon if we are being paranoid.
[[ -d ~/skype ]] || mkdir ~/skype
qvm-run --pass-io $install_vm 'cat /rw/usrlocal/share/icons/hicolor/32x32/apps/skype.png' >~/skype/skype.png
echo "qvm-run -q --tray -a $install_vm -- 'qubes-desktop-run /rw/usrlocal/share/applications/skype.desktop'">~/skype/skype.sh
chmod +x ~/skype/skype.sh

# Shutdown Skype VM to remove non-local installation remnants
qvm-shutdown --wait $install_vm

echo run ~/skype/skype.sh to run Skype in its own appVM
