# rear

Description
===========
Install and do a best effort configuration of Relax-and-Recover (ReaR).

This chef cookbook must be able to run on RHEL 6 and RHEL 7:
- RHEL 6 is still using rear-1.17.2
- RHEL 7 is using rear-2.0 (or above)
- RHEL 8 is using rear-2.4 (or above)

Basically we configure ReaR when the ${rear_netfs_url}" != "N/A" (or rear_netfs_url is not missing) in the /etc/install/config
- we remove the default 'rear' cron entry if above setting is "N/A" (or the config file is missing) as Ops complains a lot about the 'rear' cron entry failing because the BACKUP_URL= contains "N/A" which is completely garbage of course.
- however, if the file `/etc/install/config` is missing we will configure ReaR using the default settings defined in the attributes file.

Furthermore, the default recipe checks if this VM is using snapshots as backup, if yes, then we can skip the ReaR configuration unless we defined an attribute to force the ReaR configuration (`node['rear']['force_configuration']`).

Packages that we need as a pre-requisite are (same for RHEL 6 and 7):
- nfs-utils syslinux genisoimage redhat-lsb-core net-tools rear mtools

The `/etc/rear/local.conf` will be automatically configured via the predefined attributes.

Platform
========
- CentOS 6 and RHEL 6
- CentOS 7 and RHEL 7
- CentOS 8 and RHEL 8

Cookbook
========
`chef-client -r rear::default`  (runs recipe default and recipe configure)

`chef-client -r rear::unconfigure` (to define rear_netfs_url=N/A in the /etc/install/config and disable rear mkbackup)

`chef-client -r rear::remove` (to unconfigure and remove ReaR software)


Attributes
==========
- `node['rear']['force_configuration'] = false` - To force the ReaR configuration with the VM snapshot backup (normally ReaR gets disabled)
- `node['rear']['config']['backup'] = 'NETFS'` - The backup method NETFS means use NFS
- `node['rear']['config']['backup_url'] = 'nfs://nas.example.com/vol/linux_images_1/'` - The URL with the NFS archive location
- `node['rear']['config']['backup_prog_exclude'] = '( ${BACKUP_PROG_EXCLUDE[@]} '` - add any file or directory to exclude from the archive
- `node['rear']['config']['netfs_prefix'] = 'image'` - name of the sub-directory beneath the NFS archive location
- `node['rear']['config']['netfs_keep_old_backup_copy'] = 'yes'` - keep a second copy of the archive
- `node['rear']['config']['output'] = 'ISO'` - the OUTPUT method is by default an ISO image 
- `node['rear']['config']['only_include_vg'] = '( "vg00" )'` - only make an archive of vg00 by default (comment out if you want all the VGs to be included)
- `node['rear']['config']['clone_users'] = '( "${CLONE_USERS[@]}" oracle )'` - clone user information to the rescue image
- `node['rear']['config']['clone_groups'] = '( "${CLONE_GROUPS[@]}" dba )'` - clone group information to the rescue image
- `node['rear']['config']['ssh_root_password'] = '"relax"'` - a dummy password so that ssh daemon gets started on the rescue image
- `node['rear']['config']['copy_as_is'] = '( "${COPY_AS_IS[@]}" /etc/oratab clear )'` - add here additional files (or commands) to be added to the rescue image

Delivery test
=============
- `delivery local lint` or `chef exec cookstyle` 
- `delivery local syntax` or `chef exec foodcritic . --exclude spec -f any # -t \"~FC064\" -t \"~FC065\"`
- `delivery local unit` or `chef exec rspec test/`

License and Author
==================

License:: Apache 2.0

Author:: Gratien Dhaese (gratien.dhaese@gmail.com)
