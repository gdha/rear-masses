# The package ReaR required to function over NFS and to create a bootable ISO image
default['rear']['packages'] = %w(nfs-utils syslinux genisoimage redhat-lsb-core net-tools rear mtools)

# The temporary mount point required to mount NFS share onto (will be removed again)
default['rear']['temp_dir'] = '/tmp/REAR-NFS-mnt'

# The following attribute allow us to force the ReaR configuration altogether.
# In case, we define force_configuration = true then we will configure ReaR always.
default['rear']['force_configuration'] = false

# ReaR Configuration part
default['rear']['config']['backup'] = 'NETFS'
default['rear']['config']['backup_url'] = 'nfs://192.168.33.1/System/Volumes/Data/Users/gdha/exports/'
# Be aware that on next line the ')' is missing, but that is on purpose as it will be added in the configure.rb recipe
default['rear']['config']['backup_prog_exclude'] = '( ${BACKUP_PROG_EXCLUDE[@]}'
default['rear']['config']['netfs_prefix'] = 'image'
default['rear']['config']['netfs_keep_old_backup_copy'] = 'yes'
default['rear']['config']['output'] = 'ISO'
default['rear']['config']['only_include_vg'] = '( "vg00" )'
default['rear']['config']['clone_users'] = '( "${CLONE_USERS[@]}" oracle )'
default['rear']['config']['clone_groups'] = '( "${CLONE_GROUPS[@]}" dba )'
default['rear']['config']['ssh_root_password'] = '"relax"'
default['rear']['config']['copy_as_is'] = '( "${COPY_AS_IS[@]}" /etc/oratab clear )'
