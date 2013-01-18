#!/bin/bash

############################################################
# Basic functions
############################################################
function print_info {
    echo -n -e '\e[1;36m'
    echo -n $1
    echo -e '\e[0m'
}

function print_warn {
    echo -n -e '\e[1;33m'
    echo -n $1
    echo -e '\e[0m'
}

function network_benchmark() {
	print_warn "Download from $1 ($2)"
	echo "Download from $1 ($2)" >> ~/collected_data 2>&1
	DOWNLOAD_SPEED=`wget -O /dev/null $2 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}'`
	
	print_info "Got $DOWNLOAD_SPEED"
	echo "Got $DOWNLOAD_SPEED" >> ~/collected_data 2>&1
}

############################################################
# Script start
############################################################

print_info "Removing old collection-data (if applicable)"
rm -fr ~/collected_data
echo "
###############################################################################
# Benchmark - collecting data and benchmarking
###############################################################################

This script has been tested on Ubuntu & Debian only and running it on other environments may not work correctly.

To benchmark, we recommend that the VPS is either idle or has a fresh installation of the OS

WARNING: You run this script entirely at your own risk.
We accept no responsibility for any damage this script may cause. Provided on an as-is basis

"
print_warn "You can review the code at https://github.com/asimzeeshan/Benchmark if you have any concerns"
print_warn "All data is being written to ~/collected_data file for now"
print_info "Installing basic tools required ..."

apt-get clean all && apt-get update
apt-get install -y mailutils nano wget

print_info "Collecting basic data..."
hname=$( hostname )
ip=`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`
ip2=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
tram=$( free -m | awk 'NR==2 {print $2}' )
swap=$( free -m | awk 'NR==4 {print $2}' )
up=$(uptime|awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }')

echo -e "============================================================" > ~/collected_data
echo -e "Hostname                  : $hname" >> ~/collected_data
echo -e "IPv4 # 1 (KVM/XEN/VMWare) : $ip" >> ~/collected_data
echo -e "IPv4 # 2 (OpenVZ)         : $ip2 " >> ~/collected_data
echo -e "============================================================" >> ~/collected_data
echo -e "CPU model                 : $cname" >> ~/collected_data
echo -e "Number of cores           : $cores" >> ~/collected_data
echo -e "CPU frequency             : $freq MHz" >> ~/collected_data
echo -e "Total amount of ram       : $tram MB" >> ~/collected_data
echo -e "Total amount of swap      : $swap MB" >> ~/collected_data
echo -e "System uptime             : $up" >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data

print_info "Collecting general data..."
############################################################
# General data collection
############################################################
cat /proc/cpuinfo | head -8 >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data
cat /proc/cpuinfo >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data
free -m >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data
cat /proc/meminfo >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data
df -h >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data
df -i >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data
vmstat >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data

############################################################
# Disk IO tests
############################################################
print_info "Performing Classic Disk I/O tests..."

echo -e "Classic Disk I/O test # 1" >> ~/collected_data
echo -e "(dd if=/dev/zero of=iotest1 bs=64k count=16k conv=fdatasync)" >> ~/collected_data
ddtest1=$( ( dd if=/dev/zero of=iotest1 bs=64k count=16k conv=fdatasync && rm -f iotest1 ) 2>&1 ) && echo $ddtest1 >> ~/collected_data
io=$( echo $ddtest1 | awk -F, '{io=$NF} END { print io}' )
echo -e "I/O speed : $io \n" >> ~/collected_data

echo -e "Classic Disk I/O test # 2" >> ~/collected_data
echo -e "(dd if=/dev/zero of=iotest2 bs=64k count=16k conv=fdatasync)" >> ~/collected_data
ddtest2=$( ( dd if=/dev/zero of=iotest2 bs=64k count=16k conv=fdatasync && rm -f iotest2 ) 2>&1 ) && echo $ddtest2 >> ~/collected_data
io=$( echo $ddtest2 | awk -F, '{io=$NF} END { print io}' )
echo -e "I/O speed : $io \n" >> ~/collected_data

echo -e "Classic Disk I/O test # 3" >> ~/collected_data
echo -e "(dd if=/dev/zero of=iotest3 bs=64k count=16k conv=fdatasync)" >> ~/collected_data
ddtest3=$( ( dd if=/dev/zero of=iotest3 bs=64k count=16k conv=fdatasync && rm -f iotest3 ) 2>&1 ) && echo $ddtest3 >> ~/collected_data
io=$( echo $ddtest3 | awk -F, '{io=$NF} END { print io}' )
echo -e "I/O speed : $io \n" >> ~/collected_data

echo -e "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n" >> ~/collected_data

############################################################
# Advance Disk I/O tests
############################################################
print_info "Performing Advance Disk I/O tests..."

echo -e "Advance Disk I/O test # 1" >> ~/collected_data
echo -e "(dd if=/dev/zero of=iotest4 bs=1M count=1k conv=fdatasync)" >> ~/collected_data
ddtest4=$( ( dd if=/dev/zero of=iotest4 bs=1M count=1k conv=fdatasync && rm -f iotest4 ) 2>&1 ) && echo $ddtest4 >> ~/collected_data
io=$( echo $ddtest4 | awk -F, '{io=$NF} END { print io}' )
echo -e "I/O speed : $io \n" >> ~/collected_data

echo -e "Advance Disk I/O test # 2" >> ~/collected_data
echo -e "(dd if=/dev/zero of=iotest5 bs=64k count=16k conv=fdatasync)" >> ~/collected_data
ddtest5=$( ( dd if=/dev/zero of=iotest5 bs=64k count=16k conv=fdatasync && rm -f iotest5 ) 2>&1 ) && echo $ddtest5 >> ~/collected_data
io=$( echo $ddtest5 | awk -F, '{io=$NF} END { print io}' )
echo -e "I/O speed : $io \n" >> ~/collected_data

echo -e "Advance Disk I/O test # 3" >> ~/collected_data
echo -e "(dd if=/dev/zero of=iotest6 bs=1M count=1k oflag=dsync)" >> ~/collected_data
ddtest6=$( ( dd if=/dev/zero of=iotest6 bs=1M count=1k oflag=dsync && rm -f iotest6 ) 2>&1 ) && echo $ddtest6 >> ~/collected_data
io=$( echo $ddtest6 | awk -F, '{io=$NF} END { print io}' )
echo -e "I/O speed : $io \n" >> ~/collected_data

echo -e "============================================================\n" >> ~/collected_data


############################################################
# Network tests
############################################################
print_info "Performing Network tests..."

echo -e "Network download test # 1" >> ~/collected_data
network_benchmark 'Cachefly' 'http://cachefly.cachefly.net/100mb.test'

echo -e "Network download test # 2" >> ~/collected_data
network_benchmark 'Cachefly' 'http://cachefly.cachefly.net/100mb.test'

echo -e "Network download test # 3" >> ~/collected_data
network_benchmark 'Cachefly' 'http://cachefly.cachefly.net/100mb.test'
echo -e "============================================================\n" >> ~/collected_data

############################################################
# Extensive Network tests
############################################################
print_info "Performing Extensive Network tests..."
print_warn "WARNING: This will download approx 1.5GB collectively in 100MB chunks from different providers"

network_benchmark 'Cachefly' 'http://cachefly.cachefly.net/100mb.test'
network_benchmark 'Linode, Atlanta, GA, USA' 'http://atlanta1.linode.com/100MB-atlanta.bin'
network_benchmark 'Linode, Dallas, TX, USA' 'http://dallas1.linode.com/100MB-dallas.bin'
network_benchmark 'Linode, Tokyo, JP' 'http://tokyo1.linode.com/100MB-tokyo.bin'
network_benchmark 'Linode, London, UK' 'http://speedtest.london.linode.com/100MB-london.bin'
network_benchmark 'OVH, Paris, France' 'http://proof.ovh.net/files/100Mio.dat'
network_benchmark 'SmartDC, Rotterdam, Netherlands' 'http://mirror.i3d.net/100mb.bin'
network_benchmark 'Hetzner, Nuremberg, Germany' 'http://hetzner.de/100MB.iso'
network_benchmark 'iiNet, Perth, WA, Australia' 'http://ftp.iinet.net.au/test100MB.dat'
network_benchmark 'MammothVPS, Sydney, Australia' 'http://www.mammothvpscustomer.com/test100MB.dat'
network_benchmark 'Leaseweb, Haarlem, NL, USA' 'http://mirror.leaseweb.com/speedtest/100mb.bin'
network_benchmark 'Softlayer, Singapore' 'http://speedtest.sng01.softlayer.com/downloads/test100.zip'
network_benchmark 'Softlayer, Seattle, WA, USA' 'http://speedtest.sea01.softlayer.com/downloads/test100.zip'
network_benchmark 'Softlayer, San Jose, CA, USA' 'http://speedtest.sjc01.softlayer.com/downloads/test100.zip'
network_benchmark 'Softlayer, Washington, DC, USA' 'http://speedtest.wdc01.softlayer.com/downloads/test100.zip'

echo -e "============================================================\n" >> ~/collected_data

############################################################
# UnixBench
############################################################
print_info "Downloading required packages before running UnixBench 5.1.3"
apt-get install -y make gcc build-essential
wget https://github.com/asimzeeshan/Benchmark/raw/master/UnixBench5.1.3-patched.tgz --no-check-certificate -q -O - | tar -xzf -
cd UnixBench
echo -e "UnixBench in progress" >> ~/collected_data
print_info "UnixBench running in progress..."
./Run -c 1 -c `grep -c processor /proc/cpuinfo` >> ~/collected_data 2>&1

############################################################
# Cleanup
############################################################
print_info "Doing cleanup..."

unset cname
unset cores
unset freq
unset tram
unset swap
unset up
unset ddtest1
unset ddtest2
unset ddtest3
unset ddtest4
unset ddtest5
unset ddtest6
unset io
unset cachefly

print_info "Done!!"