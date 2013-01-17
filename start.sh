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
cachefly=$( wget -O /dev/null http://cachefly.cachefly.net/100mb.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo -e "Download speed from CacheFly: $cachefly \n" >> ~/collected_data

echo -e "Network download test # 2" >> ~/collected_data
cachefly=$( wget -O /dev/null http://cachefly.cachefly.net/100mb.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo -e "Download speed from CacheFly: $cachefly \n" >> ~/collected_data

echo -e "Network download test # 3" >> ~/collected_data
cachefly=$( wget -O /dev/null http://cachefly.cachefly.net/100mb.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo -e "Download speed from CacheFly: $cachefly \n" >> ~/collected_data
echo -e "============================================================\n" >> ~/collected_data

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