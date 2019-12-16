name 'rear'
maintainer 'Gratien Dhaese'
maintainer_email 'gratien.dhaese@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures rear'
long_description 'Installs/Configures rear'
version '1.0.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url '' if respond_to?(:issues_url)
source_url '' if respond_to?(:source_url)

supports 'redhat'
supports 'centos'

# List of the cookbook dependencies
depends 'line'
