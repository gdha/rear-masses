#
# Cookbook:: rear
# Recipe:: remove
#
# Copyright:: 2019, Gratien Dhaese, Apache 2.0
#

include_recipe 'rear::unconfigure'

package 'Remove rear software' do
  package_name 'rear'
  action :remove
end
