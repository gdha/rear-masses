VAR_DIR=/var/lib/rear
[[ ! -d $VAR_DIR/sysreqs ]] && mkdir -m 755 $VAR_DIR/sysreqs

############################ M A I N ########################
{
#DEBUG line
#set -x

echo
echo `hostname` - `date '+%F %R'`
echo


#
# OS information
#
#REARVER=`rpm -q --queryformat "%{VERSION}" rear`

echo "Operating system:"
if [ -f /etc/SuSE-release ]; then
  # lsb_release does not contain minor version (SP version) in SLE
  # get OS version from /etc/SuSE-release
  OSVER=`head -1 /etc/SuSE-release`
  # get OS patchlevel (SP) from /etc/SuSE-release
  OSLEVEL=`grep PATCHLEVEL /etc/SuSE-release  | cut -d= -f2`
  echo "${OSVER} SP${OSLEVEL}"
else
  /usr/bin/lsb_release  --short --description
fi
echo
echo "Relax and recover version:"
/usr/sbin/rear -V
echo

#
# CPU & Memory information
#

# get number of processor cores
PROCS=`cat /proc/cpuinfo | grep "processor" | sort -u | wc -l`
# get processor speed (assumes all processors have same speed
SPEED=`cat /proc/cpuinfo | grep "cpu MHz" | sort -u | cut -d: -f2`
# determine the amount of memory the system had (this excludes kernel memory (how to determine this?)
TOTMEM=$((`grep MemTotal /proc/meminfo | cut -d: -f2| sed 's/kB//'` / 1024))

echo "There are ${PROCS} CPU core(s) at ${SPEED} MHz"
echo "${TOTMEM} MiB of physical memory"
echo

#
# Disk information
#

# get lvm info in consice format
/var/lib/rear/recovery.sh lvm_info | grep -v " LV " | cut -d'(' -f1 | sed '$!N;N;s/\n/ /g' | sed -e "s/Needed size://" -e "s/^/    /" > /tmp/sysreq.out.$$
# get swap space size
SWAP_KB=`grep -v -e Filename -e /dev/dm- /proc/swaps | awk '{tot=tot+$3} END {print tot}'`
# get vg00 size
VG00_GB=`grep vg00 /tmp/sysreq.out.$$ | cut -d: -f2 | sed 's/GiB//'`
# get /boot size
BOOT_KB=$(grep `df -P /boot | grep /boot | awk '{print $1}' | sed "s#/dev/##"` /proc/partitions | awk '{print $3}')
# calculate needed OS disk size (= vg00 size + swap size + /boot size)
#TOTOS=`perl -e "printf '%.2f', $SWAP_KB/(1024*1024)+$VG00_GB+;"`
TOTOS=$(echo "((($SWAP_KB+$BOOT_KB)/(1024*1024))+$VG00_GB)" | bc -l)
TOTOS=$(printf '%.2f' $TOTOS)

echo "Disk space requirements:"
echo "  OS (vg00 + swap + /boot)"
echo "    size: ${TOTOS} GiB"
echo "  Additional VGs"
grep -v vg00 /tmp/sysreq.out.$$
echo

# remove temporary file 
rm  /tmp/sysreq.out.$$

#
# Network information
#

echo "Network Information:"
echo "  IP adresses:"
# all ip adresses with some extra info ( subnet + DNS name)
ip addr show | grep inet | grep -v 127.0.0. | sed -e "s/ brd.*//" -e "s/inet//" | while read ip; do
  echo "    ip ${ip%/*} subnet /${ip#*/} DNS name `dig +short -x ${ip%/*}`"
done
echo "  Default route:"
# default route
ip route show | grep default | cut -d' ' -f3 | sed -e "s/^/    /"
echo

#echo "Other System Requirements:"
#echo
} >$VAR_DIR/sysreqs/Minimal_System_Requirements.txt
