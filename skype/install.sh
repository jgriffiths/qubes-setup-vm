#!/bin/bash

# Download and install Skype locally
skype_rpm=skype-4.3.0.37-fedora.i586.rpm
skype_rpm_url=http://download.skype.com/linux/$skype_rpm
skype_rpm_file=/rw/config/$skype_rpm

sudo wget -q $skype_rpm_url -O $skype_rpm_file
sudo dnf install -y $skype_rpm_file

# Move installed files to persistent VM storage
rpm -qlp $skype_rpm_file | grep '^/usr/share' | while read file; do
    new_file=`echo $file | sed -e 's:^/usr:/rw/usrlocal:g'`
    dir_name=`dirname $new_file`
    sudo mkdir -p $dir_name
    sudo mv $file $new_file
done

if [[ -x /usr/bin/firejail ]]; then
    # We have firejail - run Skype under it
    sudo mv /usr/bin/skype /rw/usrlocal/bin/skype.bin
    sudo cat << EOF > /rw/usrlocal/bin/skype
#!/bin/bash
    exec firejail --profile=/etc/firejail/skype.profile /rw/usrlocal/bin/skype.bin
EOF
    sudo chmod +x /rw/usrlocal/bin/skype
else
    sudo mv /usr/bin/skype /rw/usrlocal/bin/
fi

# Cleanup rpm download
sudo rm $skype_rpm_file

# Symlink Skype share directory on VM startup
sudo chmod +x /rw/config/rc.local
echo "sudo ln -f -s /rw/usrlocal/share/skype/ /usr/share/skype" | sudo tee --append /rw/config/rc.local'
