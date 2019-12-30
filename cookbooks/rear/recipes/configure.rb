#
# Cookbook:: rear
# Recipe:: configure
#
# Copyright:: 2019, Gratien Dhaese, Apache 2.0

if ::File.exist?('/etc/install/config')
  # Fill attribute ['rear']['config']['backup_url'] with value "rear_netfs_url" retrieved from /etc/install/config file
  netfs_url = shell_out('grep ^rear_netfs_url /etc/install/config | cut -d= -f2-').stdout.chomp
  node.default['rear']['config']['backup_url'] = "#{netfs_url}/"
end

# Install all required packages for ReaR (we will ignore package install failures as this will be picked
# up by the rear run when a required binary is missing). Otherwise, we would break the chef-client run altogether.
node['rear']['packages'].each do |package|
  package package do
    action :install
    ignore_failure true
  end
end

# The /etc/rear/site.conf is the same on all platform across out organization
template '/etc/rear/site.conf' do
  owner  'root'
  group 'root'
  mode '0600'
  source 'site.erb'
end

# The /etc/rear/local.conf contains local settings per system. However, we will
# create an example local.conf.sample which can be used as a starter
template '/etc/rear/local.conf' do
  owner  'root'
  group 'root'
  mode '0600'
  source 'local.erb'
  not_if 'test -f /etc/rear/local.conf'
end

# We will verify the content of /etc/rear/local.conf now with our predefined attribute values
replace_or_add 'config BACKUP method' do
  path '/etc/rear/local.conf'
  pattern '^BACKUP='
  line "BACKUP=#{node['rear']['config']['backup']}"
end

# The default setting within JnJ is ONLY_INCLUDE_VG=( vg00 )
# Use BACKUP_PROG_EXCLUDE array to exclude file systems when you comment out variable ONLY_INCLUDE_VG
replace_or_add 'config only include vg00' do
  path '/etc/rear/local.conf'
  pattern '^ONLY_INCLUDE_VG='
  line "ONLY_INCLUDE_VG=#{node['rear']['config']['only_include_vg']}"
  not_if '/bin/grep -c --regex "^#.*ONLY_INCLUDE_VG" /etc/rear/local.conf'
end

# NETFS_URL is deprecated and should be replaced with BACKUP_URL
execute 'replace NETFS_URL by BACKUP_URL' do
  command 'sed -i -e "s/^NETFS_URL/BACKUP_URL/" /etc/rear/local.conf'
  only_if 'grep ^NETFS_URL= /etc/rear/local.conf'
end

# Setup out BACKUP_URL definition where we want to store our archive made by ReaR
# Only modify if it wasn't already defined yet
replace_or_add 'config BACKUP_URL' do
  path '/etc/rear/local.conf'
  pattern '^BACKUP_URL='
  line "BACKUP_URL=#{node['rear']['config']['backup_url']}#{node['fqdn']}"
  not_if '/bin/grep -e ^BACKUP_URL=nfs -e ^NETFS_URL=nfs /etc/rear/local.conf'
end

# NETFS_PREFIX setting
replace_or_add 'config NETSF_PREFIX' do
  path '/etc/rear/local.conf'
  pattern '^NETFS_PREFIX='
  line "NETFS_PREFIX=#{node['rear']['config']['netfs_prefix']}"
end

# NETFS_KEEP_OLD_BACKUP_COPY setting
replace_or_add 'config NETFS_KEEP_OLD_BACKUP_COPY' do
  path '/etc/rear/local.conf'
  pattern '^NETFS_KEEP_OLD_BACKUP_COPY='
  line "NETFS_KEEP_OLD_BACKUP_COPY=#{node['rear']['config']['netfs_keep_old_backup_copy']}"
end

# AUTOEXCLUDE_DISKS is required when we want to cover all disks (including swap)
# Do not put this to 'yes' when ONLY_INCLUDE_VG=vg00 otherwise we would format all disks
# and not only those from vg00

# BACKUP_PROG_EXCLUDE: add file systems we do not want a copy of, e.g. oracle datafiles
# We have to be careful here as we only want to add this line when it is missing as
# otherwise we would remove our 'per system' setting with our global setting again
# echo time chef-client runs (=not the desired state of course)
# We will try to figure out if system is using oracle, sap or docker:
u02_rc = shell_out('mount | grep -q /u02 ; echo $?').stdout
sap_rc = shell_out('mount | grep -q /usr/sap ; echo $?').stdout
docker_root_fs = shell_out("/bin/docker info | grep 'Docker Root Dir:' | awk '{print $4}'").stdout.chomp if ::File.exist?('/bin/docker')

begin
  exclude_fs = if u02_rc.to_i == 0
                 "'/u02/ora*' '/u02/recoveryarea01'"
               elsif sap_rc.to_i == 0
                 "'/DBEXPORT/*' '/oracle/*/mirr*' '/oracle/*/or*' '/oracle/*/sap*' '/oracle/*/flash*'"
               elsif !docker_root_fs.blank? || !docker_root_fs.nil?
                 docker_root_fs.to_s
               end
rescue
  exclude_fs = ''
end
# If we are lucky we can automatically fill in some file systems to exclude from backup
node.default['rear']['config']['exclude_fs'] = exclude_fs

replace_or_add 'config BACKUP_PROG_EXCLUDE' do
  path '/etc/rear/local.conf'
  pattern '^BACKUP_PROG_EXCLUDE='
  line "BACKUP_PROG_EXCLUDE=#{node['rear']['config']['backup_prog_exclude']} #{node['rear']['config']['exclude_fs']} )"
  not_if '/bin/grep -c ^BACKUP_PROG_EXCLUDE= /etc/rear/local.conf'
end

# CLONE_USERS: add additional users definition to the ReaR image
replace_or_add 'config CLONE_USERS' do
  path '/etc/rear/local.conf'
  pattern '^CLONE_USERS='
  line "CLONE_USERS=#{node['rear']['config']['clone_users']}"
end

# CLONE_GROUPS: add additional group definitions to the ReaR image
replace_or_add 'config CLONE_GROUPS' do
  path '/etc/rear/local.conf'
  pattern '^CLONE_GROUPS='
  line "CLONE_GROUPS=#{node['rear']['config']['clone_groups']}"
end

# SSH_ROOT_PASSWORD: when we add this to the ReaR image the sshd will be started
# so that we could login from a putty instead of only using the console
# However, if a setting was already present then do not replace it with this value
replace_or_add 'config SSH_ROOT_PASSWORD' do
  path '/etc/rear/local.conf'
  pattern '^SSH_ROOT_PASSWORD='
  line "SSH_ROOT_PASSWORD=#{node['rear']['config']['ssh_root_password']}"
  not_if '/bin/grep -c ^SSH_ROOT_PASSWORD /etc/rear/local.conf'
end

# COPY_AS_IS: copy additional files or executables to the ReaR image
replace_or_add 'config COPY_AS_IS' do
  path '/etc/rear/local.conf'
  pattern '^COPY_AS_IS='
  line "COPY_AS_IS=#{node['rear']['config']['copy_as_is']}"
  not_if '/bin/grep -c ^COPY_AS_IS /etc/rear/local.conf'
end

# Hopefully a temporary hack to fix /etc/udev/rules.d/90-eno-fix.rules via ReaR
# As long a we do not have a UDEV_RULE_FILES in the default.conf file we have to keep this
replace_or_add 'fix script 55-migrate-network-devices.sh for eno LAN' do
  path '/usr/share/rear/skel/default/etc/scripts/system-setup.d/55-migrate-network-devices.sh'
  pattern '^RULE_FILES='
  line 'RULE_FILES=( /etc/udev/rules.d/*persistent*{names,net,cd}.rules /etc/udev/rules.d/*eno-fix.rules )'
end

# Same for /usr/share/rear/finalize/GNU/Linux/410_migrate_udev_rules.sh (on rear-2.00)
# Be careful as this script is renamed to 310_migrate_udev_rules.sh in rear-2.5 (back-ported?)
replace_or_add 'fix script 410_migrate_udev_rules.sh for eno LAN' do
  path '/usr/share/rear/finalize/GNU/Linux/410_migrate_udev_rules.sh'
  pattern '^RULE_FILES='
  line 'RULE_FILES=( /etc/udev/rules.d/*persistent*{names,net,cd}.rules /etc/udev/rules.d/*eno-fix.rules )'
end

# As we are using NFS to mount a remote NAS filer we need to verify that local
# NFS services are running and enabled. As we are supporting different Linux
# flavors and versions we need to work with if-blocks
# For RHEL 6 and 7:
service 'rpcbind_rear' do
  service_name 'rpcbind'
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

# Start NFS services on RHEL 6:
service 'nfs_rear' do
  service_name 'nfs'
  action [:enable, :start]
  only_if { platform_family?('rhel') && node['platform_version'].to_i == 6 }
end

# Start NFS statd daemon for RHEL 7:
service 'rpc-statd_rear' do
  service_name 'rpc-statd'
  supports status: true, restart: true, reload: true
  action [:enable, :start]
  only_if { platform_family?('rhel') && node['platform_version'].to_i == 7 }
end

# Start nfs-client for RHEL 7:
service 'nfs-client.target_rear' do
  service_name 'nfs-client.target'
  supports status: true, restart: true, reload: true
  action [:enable, :start]
  only_if { platform_family?('rhel') && node['platform_version'].to_i == 7 }
end

if ::File.exist?('/etc/install/config')
  # We require to have on the remote NFS server a store for our systems based on FQDN
  nfs_server = shell_out('grep ^rear_netfs_url /etc/install/config | cut -d= -f2- | cut -d: -f1').stdout.chomp
  nfs_path = shell_out('grep ^rear_netfs_url /etc/install/config | cut -d= -f2- | cut -d: -f2-').stdout.chomp
else
  nfs_server = shell_out('grep ^BACKUP_URL /etc/rear/local.conf | cut -d/ -f3').stdout.chomp
  nfs_path = shell_out('grep ^BACKUP_URL /etc/rear/local.conf | cut -d/ -f4-').stdout.chomp
end

# Create a temporary directory under /tmp to mount the NFS share onto
# If the /var/lib/rear/layout/disklayout.conf file exists then ReaR did already run once (no need for this anymore)
directory 'create temp dir for NFS mounting' do
  path node['rear']['temp_dir']
  recursive true
  action :create
  not_if 'test -f /var/lib/rear/layout/disklayout.conf'
end

# mount the NFS share locally
mount node['rear']['temp_dir'] do
  device "#{nfs_server}:/#{nfs_path}"
  fstype 'nfs'
  options 'rw'
  not_if 'test -f /var/lib/rear/layout/disklayout.conf'
end

# Create the private mount point for this system (based on its FQDN) on the NFS share
directory 'remote ReaR drop location on nfs server' do
  path "#{node['rear']['temp_dir']}/#{node['fqdn']}"
  action :create
  not_if 'test -f /var/lib/rear/layout/disklayout.conf'
end

# Unmount temporary directory again
execute 'unmount the temporary rear directory' do
  command "umount #{node['rear']['temp_dir']}"
  not_if 'test -f /var/lib/rear/layout/disklayout.conf'
end

if platform_family?('rhel') && node['platform_version'].to_i == 6
  # copy 2 extra scripts for rear-1.7.2 and RHEL 6 only
  cookbook_file '/usr/share/rear/rescue/GNU/Linux/99_sysreqs.sh' do
    owner 'root'
    group 'root'
    mode '0644'
    source '99_sysreqs.sh'
  end

  cookbook_file '/usr/share/rear/finalize/Fedora/i386/16_lvm.conf.sh' do
    owner 'root'
    group 'root'
    mode '0644'
    source '16_lvm.conf.sh'
  end

  # Fix for failing parted rear-1.17.2 on RHEL 6 (is fixed in rear-2.00 on RHEL 7)
  # rear-2.00 (RHEL 7) and above uses 3 digits instead of 2 digits in front of script name
  execute 'Add sleep 1 after parted in script 10_include_partition_code.sh' do
    command 'sed -i -e "/^parted /asleep 1" /usr/share/rear/layout/prepare/GNU/Linux/10_include_partition_code.sh'
    # action :nothing
    only_if 'test -f /usr/share/rear/layout/prepare/GNU/Linux/10_include_partition_code.sh && ! /bin/grep -q "sleep 1" /usr/share/rear/layout/prepare/GNU/Linux/10_include_partition_code.sh'
  end
end

if platform_family?('rhel') && node['platform_version'].to_i == 7
  # On RHEL 7 updated from an old rear version we might still have these 2 extra script
  # which copied seperately and therefore, never removed by YUM. So, we have to remove them
  file 'Remove 16_lvm.conf.sh on RHEL 7' do
    path '/usr/share/rear/finalize/Fedora/i386/16_lvm.conf.sh'
    action :delete
  end

  file 'Remove 99_sysreqs.sh on RHEL 7' do
    path '/usr/share/rear/rescue/GNU/Linux/99_sysreqs.sh'
    action :delete
  end
end

# Install the weekly "rear mkbackup" cron entry
template '/etc/cron.weekly/rear' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'rear.cron'
end
