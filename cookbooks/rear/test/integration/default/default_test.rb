# encoding: utf-8

# Inspec test for recipe rear::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('rear') do
  it { should be_installed }
end
describe file('/etc/rear/local.conf') do
  it { should exist }
  its('content') { should match(/BACKUP=NETFS/) }
  its('content') { should match(%r{^BACKUP_URL=nfs:\/\/}) }
end
