# rear-masses
## Relax-and-Recover (ReaR) Mass Deployment with Chef cookbook

This repository contains the Chef cookbook for installing and configuring ReaR.

## Pre-requisites

- A linux or OS/x system
- git
- virtualbox
- Chef Workstation

## Getting started

Clone this repository with git:

````
git clone https://github.com/gdha/rear-masses.git
cd rear-masses/cookbooks/rear
````

## Create the test VM

````
$ kitchen list
Instance          Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-centos-7  Vagrant  ChefSolo     Inspec    Ssh        <Not Created>  <None>

$ kitchen create
-----> Starting Test Kitchen (v2.3.4)
-----> Creating <default-centos-7>...
       Bringing machine 'default' up with 'virtualbox' provider...
       ==> default: Importing base box 'bento/centos-7'...
==> default: Matching MAC address for NAT networking...
       ==> default: Checking if box 'bento/centos-7' version '201910.20.1' is up to date...
       ==> default: A newer version of the box 'bento/centos-7' for provider 'virtualbox' is
       ==> default: available! You currently have version '201910.20.1'. The latest is version
       ==> default: '201912.14.0'. Run `vagrant box update` to update.
       ==> default: Setting the name of the VM: kitchen-rear-default-centos-7-7eaf9a34-c993-488f-bc77-106d039f5a2b
       ==> default: Clearing any previously set network interfaces...
       ==> default: Preparing network interfaces based on configuration...
           default: Adapter 1: nat
           default: Adapter 2: hostonly
       ==> default: Forwarding ports...
           default: 22 (guest) => 2222 (host) (adapter 1)
       ==> default: Running 'pre-boot' VM customizations...
       ==> default: Booting VM...
       ==> default: Waiting for machine to boot. This may take a few minutes...
           default: SSH address: 127.0.0.1:2222
           default: SSH username: vagrant
           default: SSH auth method: private key
           default: Warning: Connection reset. Retrying...
           default: 
           default: Vagrant insecure key detected. Vagrant will automatically replace
           default: this with a newly generated keypair for better security.
           default: 
           default: Inserting generated public key within guest...
           default: Removing insecure key from the guest if it's present...
           default: Key inserted! Disconnecting and reconnecting using new SSH key...
       ==> default: Machine booted and ready!
       ==> default: Checking for guest additions in VM...
       ==> default: Setting hostname...
       ==> default: Configuring and enabling network interfaces...
       ==> default: Mounting shared folders...
           default: /etc/install => /Users/gdha/data/projects/devops/rear-masses/install
           default: /tmp/omnibus/cache => /Users/gdha/.kitchen/cache
       ==> default: Machine not provisioned because `--no-provision` is specified.
       [SSH] Established
       Vagrant instance <default-centos-7> created.
       Finished creating <default-centos-7> (1m11.74s).
-----> Test Kitchen is finished. (1m17.47s)
````

You can login on this Centos-7 VM with the command `kitchen login` and checking the VM environment. For example, you can verify if ReaR was already installed or not?

````
$ rpm -q rear
package rear is not installed
````

Or, check the `/etc/install/config` file:

````
$ cat /etc/install/config 
#rear_netfs_url=N/A
rear_netfs_url=192.168.33.1:/System/Volumes/Data/Users/gdha/exports
````

You probably want to change the rear_netfs_url variable to a proper and working NFS location, otherwise, the ReaR configuration will fail with a NFS mount error and bail out the cookbook.

To test the cookbook just run `kitchen converge`:
````$ kitchen converge
-----> Starting Test Kitchen (v2.3.4)
-----> Converging <default-centos-7>...
       Preparing files for transfer
       Preparing dna.json
       Resolving cookbook dependencies with Berkshelf 7.0.8...
       Removing non-cookbook files before transfer
       Preparing solo.rb
-----> Installing Chef install only if missing package
       Downloading https://omnitruck.chef.io/install.sh to file /tmp/install.sh
       Trying wget...
       Download complete.
       el 7 x86_64
       Getting information for chef stable  for el...
       downloading https://omnitruck.chef.io/stable/chef/metadata?v=&p=el&pv=7&m=x86_64
         to file /tmp/install.sh.12138/metadata.txt
       trying wget...
       sha1	27c8caeb7fcbab3642d3a2c320d2f880a6cf8541
       sha256	9cb48fed74779b261a03c34178e375bbbf27860db3641ef5b392f7b1e439414e
       url	https://packages.chef.io/files/stable/chef/15.6.10/el/7/chef-15.6.10-1.el7.x86_64.rpm
       version	15.6.10
       downloaded metadata file looks valid...
       /tmp/omnibus/cache/chef-15.6.10-1.el7.x86_64.rpm exists
       Comparing checksum with sha256sum...
       
       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
       
       You are installing a package without a version pin.  If you are installing
       on production servers via an automated process this is DANGEROUS and you will
       be upgraded without warning on new releases, even to new major releases.
       Letting the version float is only appropriate in desktop, test, development or
       CI/CD environments.
       
       WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING
       
       Installing chef 
       installing with rpm...
       warning: /tmp/omnibus/cache/chef-15.6.10-1.el7.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 83ef826a: NOKEY
       Preparing...                          ################################# [100%]
       Updating / installing...
          1:chef-15.6.10-1.el7               ################################# [100%]
       Thank you for installing Chef Infra Client! For help getting started visit https://learn.chef.io
       Transferring files to <default-centos-7>
       +---------------------------------------------+
       ✔ 2 product licenses accepted.
       +---------------------------------------------+
       Starting Chef Infra Client, version 15.6.10
       Creating a new client identity for default-centos-7 using the validator key.
       resolving cookbooks for run list: ["rear::default"]
       Synchronizing Cookbooks:
         - rear (1.0.0)
         - line (2.5.0)
       Installing Cookbook Gems:
       Compiling Cookbooks...
       Converging 34 resources
       Recipe: rear::default
         * file[/etc/cron.d/rear] action delete (up to date)
       Recipe: rear::configure
         * yum_package[nfs-utils] action install (up to date)
         * yum_package[syslinux] action install
           - install version 0:4.05-15.el7.x86_64 of package syslinux
         * yum_package[genisoimage] action install
           - install version 0:1.1.11-25.el7.x86_64 of package genisoimage
         * yum_package[redhat-lsb-core] action install
           - install version 0:4.1-27.el7.centos.1.x86_64 of package redhat-lsb-core
         * yum_package[net-tools] action install (up to date)
         * yum_package[rear] action install
           - install version 0:2.4-10.el7_7.x86_64 of package rear
         * yum_package[mtools] action install (up to date)
         * template[/etc/rear/site.conf] action create
           - create new file /etc/rear/site.conf
           - update content in file /etc/rear/site.conf from none to ea66d0
           --- /etc/rear/site.conf	2019-12-30 09:58:32.869123910 +0000
           +++ /etc/rear/.chef-site20191230-12265-1pa8nvz.conf	2019-12-30 09:58:32.869123910 +0000
           @@ -1 +1,5 @@
           +# THIS FILE IS CONTROLLED BY CHEF
           +COPY_AS_IS=( "${COPY_AS_IS[@]}" /etc/install/config /usr/bin/perl /usr/lib64/perl5/CORE/libperl.so /usr/bin/seq /sbin/lspci )
           +RESULT_FILES=( $VAR_DIR/sysreqs/Minimal_System_Requirements.txt )
           +OUTPUT=ISO
           - change mode from '' to '0600'
           - change owner from '' to 'root'
           - change group from '' to 'root'
           - restore selinux security context
         * template[/etc/rear/local.conf] action create (skipped due to not_if)
         * replace_or_add[config BACKUP method] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from 41ad2a to c24707
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config only include vg00] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from c24707 to f78caf
             - suppressed sensitive resource
             - restore selinux security context
         
         * execute[replace NETFS_URL by BACKUP_URL] action run (skipped due to only_if)
         * replace_or_add[config BACKUP_URL] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from f78caf to db2cc4
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config NETSF_PREFIX] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from db2cc4 to 498499
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config NETFS_KEEP_OLD_BACKUP_COPY] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from 498499 to 791f5d
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config BACKUP_PROG_EXCLUDE] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from 791f5d to 02c8f7
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config CLONE_USERS] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from 02c8f7 to d7b160
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config CLONE_GROUPS] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from d7b160 to 1ae177
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config SSH_ROOT_PASSWORD] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from 1ae177 to 9aa47a
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[config COPY_AS_IS] action edit
           * file[/etc/rear/local.conf] action create
             - update content in file /etc/rear/local.conf from 9aa47a to 91b6a5
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[fix script 55-migrate-network-devices.sh for eno LAN] action edit
           * file[/usr/share/rear/skel/default/etc/scripts/system-setup.d/55-migrate-network-devices.sh] action create
             - update content in file /usr/share/rear/skel/default/etc/scripts/system-setup.d/55-migrate-network-devices.sh from 4df16e to 3230fd
             - suppressed sensitive resource
             - restore selinux security context
         
         * replace_or_add[fix script 410_migrate_udev_rules.sh for eno LAN] action edit
           * file[/usr/share/rear/finalize/GNU/Linux/410_migrate_udev_rules.sh] action create
             - create new file /usr/share/rear/finalize/GNU/Linux/410_migrate_udev_rules.sh
             - update content in file /usr/share/rear/finalize/GNU/Linux/410_migrate_udev_rules.sh from none to 71a729
             - suppressed sensitive resource
             - restore selinux security context
         
         * service[rpcbind_rear] action enable (up to date)
         * service[rpcbind_rear] action start (up to date)
         * service[nfs_rear] action enable (skipped due to only_if)
         * service[nfs_rear] action start (skipped due to only_if)
         * service[rpc-statd_rear] action enable (up to date)
         * service[rpc-statd_rear] action start
           - start service service[rpc-statd_rear]
         * service[nfs-client.target_rear] action enable (up to date)
         * service[nfs-client.target_rear] action start (up to date)
         * directory[create temp dir for NFS mounting] action create
           - create new directory /tmp/REAR-NFS-mnt
           - restore selinux security context
         * mount[/tmp/REAR-NFS-mnt] action mount
           - mount 192.168.33.1://System/Volumes/Data/Users/gdha/exports to /tmp/REAR-NFS-mnt
         * directory[remote ReaR drop location on nfs server] action create (up to date)
         * execute[unmount the temporary rear directory] action run
           - execute umount /tmp/REAR-NFS-mnt
         * file[Remove 16_lvm.conf.sh on RHEL 7] action delete (up to date)
         * file[Remove 99_sysreqs.sh on RHEL 7] action delete (up to date)
         * template[/etc/cron.weekly/rear] action create
           - create new file /etc/cron.weekly/rear
           - update content in file /etc/cron.weekly/rear from none to d38763
           --- /etc/cron.weekly/rear	2019-12-30 09:58:34.374140496 +0000
           +++ /etc/cron.weekly/.chef-rear20191230-12265-1y8hzrh	2019-12-30 09:58:34.374140496 +0000
           @@ -1 +1,3 @@
           +/usr/sbin/rear mkbackup > /dev/null 2>&1
           +echo exit code $? >> /var/log/rear/rear-$(hostname -s).log
           - change mode from '' to '0755'
           - change owner from '' to 'root'
           - change group from '' to 'root'
           - restore selinux security context
       
       Running handlers:
       Running handlers complete
       Chef Infra Client finished, 34/50 resources updated in 19 seconds
       Downloading files from <default-centos-7>
       Finished converging <default-centos-7> (0m35.32s).
-----> Test Kitchen is finished. (0m41.89s)
````

