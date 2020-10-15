#!/bin/bash
echo -e "-------------------------------System Information----------------------------"
echo -e "Hostname:\t\t"`hostname`
echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
echo -e "Product Name:\t\t"`cat /sys/class/dmi/id/product_name`
echo -e "Version:\t\t"`cat /sys/class/dmi/id/product_version`
if [ $UID = 0 ]; then echo -e "Serial Number:\t\t"`cat /sys/class/dmi/id/product_serial`; fi
echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "Kernel:\t\t\t"`uname -r`
echo -e "Architecture:\t\t"`arch`
echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
echo -e "System Main IP:\t\t"`hostname -I`
echo ""
echo -e "-------------------------------CPU/Memory Usage------------------------------"
echo -e `free -t | awk 'NR == 2 {print "Memory Usage % : " $3/$2*100}'`
echo -e `free -t | awk 'NR == 3 {print "Swap Usage % : " $3/$2*100}'`
echo -e `cat /proc/stat | grep -w "cpu" | awk '{print "CPU Usage % : " ($2+$4)*100/($2+$4+$5)}'`
echo ""
echo -e "-------------------------------Disk Usage >80%-------------------------------"
df -Ph | grep -v "snap" | sed s/%//g | awk '{ if($5 > 80) print $0;}'
echo ""
exit 0

