if ! diff -q /etc/lvm/lvm.conf /mnt/local/etc/lvm/lvm.conf; then
  # copy modified /etc/lvm/lvm.conf
  cp /etc/lvm/lvm.conf /mnt/local/etc/lvm/lvm.conf
fi
