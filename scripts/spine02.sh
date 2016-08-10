#!/bin/bash -ex
##### 
# Script thuc thi tren node spine02
#####

# Setup network
cp  /etc/network/interfaces  /etc/network/interfaces.orig

cat << EOF > /etc/network/interfaces

# The loopback network interface
auto lo
  iface lo inet loopback
  address 10.2.1.4/32

# The primary network interface
auto eth0
  iface eth0 inet dhcp

auto swp1
  iface swp1
  address 10.2.1.4/32

auto swp2
  iface swp2
  address 10.2.1.4/32

auto swp3
  iface swp3
EOF

# Configure Quagga /etc/quagga/daemons
sed -i 's/zebra=no/zebra=yes/g' /etc/quagga/daemons
sed -i 's/bgpd=no/bgpd=yes/g' /etc/quagga/daemons
sed -i 's/ospfd=no/ospfd=yes/g' /etc/quagga/daemons

# Create /etc/quagga/Quagga.conf

cat << EOF > /etc/quagga/Quagga.conf
service integrated-vtysh-config 

interface swp1
  ip ospf network point-to-point

interface swp2
  ip ospf network point-to-point

router-id 10.2.1.4

router ospf
  ospf router-id 10.2.1.4
  network 10.2.1.4/32 area 0.0.0.0
EOF

# Restart networking 
systemctl restart networking

# Restart Quagga
systemctl restart quagga.service

