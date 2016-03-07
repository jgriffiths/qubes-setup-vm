# Useful functions to call from dom0

# Add kernel boot options to a VM
# args: vm_name option1 option2 ... optionN
vm_add_kernel_options() {
    local vm=$1;

    local opts=$(qvm-prefs -g $vm kernelopts | sed -e '/ \(default\)/d')
    qvm-prefs --set $vm kernelopts "$opts $*"
}

# Add command to VMs rc.local and set rc.local executable
# args: vm_name, 'shell command'
vm_add_to_rc_local() {
    local vm=$1; shift

    qvm-run --auto $vm "sudo chmod +x /rw/config/rc.local && \
        echo \"$*\" | sudo tee --append /rw/config/rc.local"
}

# Get rid of audit and systemd log spam
# args: vm_name
vm_less_logging() {
    local vm=$1;

    # Disable audit at kernel boot, anything less just doesn't work
    # to stem the tide of audit spam
    vm_add_kernel_options $vm audit=0

    # Avoid screeds of systemd logging
    # 'systemd-analyze set-log-level <anything>' doesn't work
    # We have to sed the config file and HUP it.
    # Set the journal limit to 1MB while we are there.
    vm_add_to_rc_local $vm "sudo sed -i -e 's/#MaxLevelStore=.*/MaxLevelStore=notice/g' \
        -e 's/#MaxLevelSyslog=.*/MaxLevelSyslog=notice/g' \
        -e 's/#SystemMaxUse=.*/SystemMaxUse=1M/g' \
        -e 's/#SystemMaxFileSize=.*/SystemMaxFileSize=1M/g' /etc/systemd/journald.conf"

    # HUPping like a normal daemon doesn't work, we have to restart instead.
    vm_add_to_rc_local $vm 'sudo systemctl restart systemd-journald'

    # Journald ignores our space reconfiguration until we manually clean up.
    vm_add_to_rc_local $vm 'sudo journalctl --vacuum-size=1M'

    # Even after this journald claims it is configured to use either 8 or 64M
    # of disk space (8M per journal and 64 M in total? Who knows).
}

vm_services_action() {
    local vm=$1; shift
    local action=$1; shift

    for service in $*; do
        qvm-service $vm $action $service
    done
}

# Minimise the services running in a VM
# args: vm
vm_minimum_services() {
    vm_services_action $1 --disable cups qubes-update-check
}

# Disable the ability to sudo from a VM
# args: vm
vm_remove_sudo() {
    local vm=$1; shift
    vm_add_to_rc_local $vm "echo 'user ALL=(ALL) ALL' | sudo tee /etc/sudoers.d/qubes"
    vm_add_to_rc_local $vm "sudo rm -f /etc/polkit-1/rules.d/00-qubes-allow-all.rules \
        /etc/polkit-1/localauthority/50-local.d/qubes-allow-all.pkla"
}

# Create a VM if it doesn't already exist
# args: vm template_vm net_vm
vm_create() {
    local vm=$1

    if qvm-check -q $vm; then
        return 1
    fi

    # Create development VM from template VM
    qvm-create --label red --template $2 $vm

    # Set the net vm for the development VM
    qvm-prefs --set $vm netvm $3

    return 0
}

_vm_spec() { echo $1 | sed 's/:.*//g'; }
_fn_spec() { echo $1 | sed 's/.*://g'; }
_cleanup() { rm -f $1; rmdir $(dirname $1); }

# Transfer a file from one VM to another
# args: source_vm:/path/to/file1 dest_vm:/path/to/file2
vm_transfer() {
    local src_vm=$(_vm_spec $1); local src_fn=$(_fn_spec $1)
    local dst_vm=$(_vm_spec $2); local dst_fn=$(_fn_spec $2)

    # Delete any recieving file from a previous failed copy
    qvm-run --auto --pass-io $dst_vm "rm -f /home/user/QubesIncoming/dom0/f 2>/dev/null"

    temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/vm_transfer_XXXXXX") ||
        { echo "failed to create temp dir for copy"; return 1; }

    # Copy source to dom0 temp file
    qvm-run --auto --pass-io $src_vm "cat $src_fn" >$temp_dir/f || { _cleanup $temp_dir/f; return 1; }
    # Copy dom0 temp file to dest incoming directory
    qvm-copy-to-vm $dst_vm $temp_dir/f || { _cleanup $temp_dir/f; return 1; }
    # Move dest incoming directory file to final location
    qvm-run --auto --pass-io $dst_vm "mv -f /home/user/QubesIncoming/dom0/f $dst_fn" || { _cleanup $temp_dir/f && return 1; }

    _cleanup $temp_dir/f
    return 0
}
