#
# Cookbook:: rear
# Recipe:: unconfigure
#
# Copyright:: 2019, Gratien Dhaese, Apache 2.0
#

replace_or_add 'Set rear_netfs_url to N/A in /etc/install/config' do
  path '/etc/install/config'
  pattern '^rear_netfs_url='
  line 'rear_netfs_url=N/A'
  only_if 'test -f /etc/install/config'
end

file 'Remove weekly cron ReaR backup' do
  path '/etc/cron.weekly/rear'
  action :delete
end
