#
# Cookbook:: rear
# Recipe:: default
#
# Copyright:: 2019, Gratien Dhaese, Apache 2.0

# cookbook will only work on Linux distributions
return if platform?('windows')

require 'chef/mixin/shell_out'

# A ReaR wrapper cookbook could contain:
# include_recipe 'rear::default' unless ::File.exist?('/etc/install/config')

# ReaR scheduling should not be active; by default, if the default rear cron exists, just remove it.
# The advantage is that on OPC, AWS or AZR ReaR will never be trigger by the default cron entry
# which is automatically installed by the 'rear' package (if rear was installed manually somehow)
file '/etc/cron.d/rear' do
  action :delete
end

################# if file /etc/install/config is present ###################
if ::File.exist?('/etc/install/config')

  # Use the netfs_url from the /etc/install/config file
  netfs_url = shell_out('grep ^rear_netfs_url /etc/install/config | cut -d= -f2-').stdout.chomp
  # if the netfs_url would be empty (or missing) in the /etc/install/config file, then set it to N/A
  netfs_url = 'N/A' if netfs_url.nil? || netfs_url.to_s.empty?
  # Write the netfs_url variable to stdout
  Chef::Log.info "ReaR setting of netfs_url=#{netfs_url}"
  # If the netfs_url=N/A we return immediately (no further config is required)
  return if netfs_url == 'N/A'

  # check NBU - using VM snapshot to backup - yes: then no ReaR backup needed unless force_configuration is true
  rc_out = shell_out("LANG=C /usr/openv/netbackup/bin/bpclimagelist -client node['hostname'].downcase.to_s >/dev/null ; echo $?").stdout
  # when rc_out output is 0 then we are using NBU VM snapshots to backup - skip ReaR configuration is ok

  Chef::Log.info 'Linux VM is using NBU snapshot (no ReaR backup needed)' if rc_out == '0'
  Chef::Log.info 'ReaR configuration is forced' if node['rear']['force_configuration'] == true

  return if rc_out == '0' && node['rear']['force_configuration'] == false

end

include_recipe 'rear::configure'
