# Ghi chép về Cumulus

## Cài đặt
- Tạo các Vmnet trong VMware Workstation từ VMnet1 đến VMnet12. Để chế độ ko cấp DHCP: Xem hình http://prntscr.com/c3gdo7
- Đăng ký tài khoản và download CumulusLinux VX (bản free) từ https://cumulusnetworks.com/cumulus-vx/ dành cho VMware (VMware Workstation, ESXi)
- Import các máy ảo down từ trang chủ của Cumulus dành cho VMware Workstation

### Máy 01 - leaf01

- Cấu hình như sau: http://prntscr.com/c3gfpl
- Thiết lập network
 - NIC01: NAT
 - NIC02: VMnet2
 - NIC03: VMnet3
 - NIC04: VMnet9
- RAM, CPU, DISK để mặc định



### Máy 02 - leaf02

- Cấu hình như sau: http://prntscr.com/c3gfxe
- Thiết lập network
 - NIC01: NAT
 - NIC02: VMnet4
 - NIC03: VMnet5
 - NIC04: VMnet10
- RAM, CPU, DISK để mặc định



### Máy 03 - spine01

- Cấu hình như sau: http://prntscr.com/c3gg2p
- Thiết lập network
    - NIC01: NAT
    - NIC02: VMnet2
    - NIC03: VMnet4
    - NIC04: VMnet11
- RAM, CPU, DISK để mặc định

### Máy 04 - spine02

- Cấu hình như sau: http://prntscr.com/c3gg8k
- Thiết lập network
    - NIC01: NAT
    - NIC02: VMnet3
    - NIC03: VMnet5
    - NIC04: VMnet12
- RAM, CPU, DISK để mặc định
 
- Đăng nhập sau khi import file vào VMware

    ```sh
    User: cumulus
    Password: CumulusLinux!
    ```


## Cấu hình

### Cấu hình trên leaf01

- Setup network

    ```sh
    cp  /etc/network/interfaces  /etc/network/interfaces.orig

    cat << EOF > /etc/network/interfaces

    # The loopback network interface
    auto lo
      iface lo inet loopback
      address 10.2.1.1/32

    # The primary network interface
    auto eth0
      iface eth0 inet dhcp

    auto swp1
      iface swp1
      address 10.2.1.1/32

    auto swp2
      iface swp2
      address 10.2.1.1/32

    auto swp3
      iface swp3
      address 10.4.1.1/24
      
    EOF
    ```

- Configure Quagga `/etc/quagga/daemons`

    ```sh
    sed -i 's/zebra=no/zebra=yes/g' /etc/quagga/daemons
    sed -i 's/bgpd=no/bgpd=yes/g' /etc/quagga/daemons
    sed -i 's/ospfd=no/ospfd=yes/g' /etc/quagga/daemons
    ```
    
- Tạo file `/etc/quagga/Quagga.conf` với nội dung như sau: 

    ```sh
    cat << EOF > /etc/quagga/Quagga.conf
    service integrated-vtysh-config

    interface swp1
      ip ospf network point-to-point

    interface swp2
      ip ospf network point-to-point

    router-id 10.2.1.1

    router ospf
      ospf router-id 10.2.1.1
      network 10.2.1.1/32 area 0.0.0.0
      network 10.4.1.0/24 area 0.0.0.0
    EOF
    ```
    
- Khởi động lại network

    ```sh
    systemctl restart networking
    ```
    
- Khởi động lại Quagga
 
    ```sh
    systemctl restart quagga.service
    ```
    
### Cấu hình trên leaf02

- Setup network

    ```sh
    cp  /etc/network/interfaces  /etc/network/interfaces.orig

    cat << EOF > /etc/network/interfaces

    # The loopback network interface
    auto lo
      iface lo inet loopback
      address 10.2.1.2/32

    # The primary network interface
    auto eth0
      iface eth0 inet dhcp

    auto swp1
      iface swp1
      address 10.2.1.2/32

    auto swp2
      iface swp2
      address 10.2.1.2/32

    auto swp3
      iface swp3
      address 10.4.2.1/24

    EOF
    ```
    

- Configure Quagga `/etc/quagga/daemons`

    ```sh
    sed -i 's/zebra=no/zebra=yes/g' /etc/quagga/daemons
    sed -i 's/bgpd=no/bgpd=yes/g' /etc/quagga/daemons
    sed -i 's/ospfd=no/ospfd=yes/g' /etc/quagga/daemons
    ```
    
- Configure Quagga `/etc/quagga/daemons`

    ```sh
    cat << EOF > /etc/quagga/Quagga.conf
    service integrated-vtysh-config 

    interface swp1
      ip ospf network point-to-point

    interface swp2
      ip ospf network point-to-point

    router-id 10.2.1.2

    router ospf
      ospf router-id 10.2.1.2                                                           
      network 10.2.1.2/32 area 0.0.0.0  
      network 10.4.2.0/24 area 0.0.0.0
    EOF
    ```
    
- Khởi động lại network

    ```sh
    systemctl restart networking
    ```
    
- Khởi động lại Quagga
 
    ```sh
    systemctl restart quagga.service
    ```
    
### Cấu hình trên Spine01

- Setup network

    ```sh
    cp  /etc/network/interfaces  /etc/network/interfaces.orig

    cat << EOF > /etc/network/interfaces

    # The loopback network interface
    auto lo
        iface lo inet loopback
        address 10.2.1.3/32

    # The primary network interface
    auto eth0
        iface eth0 inet dhcp

    auto swp1
        iface swp1
        address 10.2.1.3/32

    auto swp2
        iface swp2
        address 10.2.1.3/32

    auto swp3
        iface swp3
      
    EOF
    ```

- Configure Quagga `/etc/quagga/daemons`

    ```sh
    sed -i 's/zebra=no/zebra=yes/g' /etc/quagga/daemons
    sed -i 's/bgpd=no/bgpd=yes/g' /etc/quagga/daemons
    sed -i 's/ospfd=no/ospfd=yes/g' /etc/quagga/daemons
    ```
    
- Tạo file `/etc/quagga/Quagga.conf` với nội dung như sau: 

    ```sh
    cat << EOF > /etc/quagga/Quagga.conf
    service integrated-vtysh-config 

    interface swp1
      ip ospf network point-to-point

    interface swp2
      ip ospf network point-to-point

    router-id 10.2.1.3

    router ospf
      ospf router-id 10.2.1.3
      network 10.2.1.3/32 area 0.0.0.0  
    EOF
    ```
    
- Khởi động lại network

    ```sh
    systemctl restart networking
    ```
    
- Khởi động lại Quagga
 
    ```sh
    systemctl restart quagga.service
    ```
    

### Cấu hình trên Spine02

- Setup network

    ```sh
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
    ```

- Configure Quagga `/etc/quagga/daemons`

    ```sh
    sed -i 's/zebra=no/zebra=yes/g' /etc/quagga/daemons
    sed -i 's/bgpd=no/bgpd=yes/g' /etc/quagga/daemons
    sed -i 's/ospfd=no/ospfd=yes/g' /etc/quagga/daemons
    ```
    
- Tạo file `/etc/quagga/Quagga.conf` với nội dung như sau: 

    ```sh
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
```
    
- Khởi động lại network

    ```sh
    systemctl restart networking
    ```
    
- Khởi động lại Quagga
 
    ```sh
    systemctl restart quagga.service
    ```
   
   
### Kiểm tra 

- Đứng trên máy leaf01 ping lần lượt tới các máy sau

    ```sh
    # Ping tới leaf02
    ping 10.2.1.2

    # Ping tới Spine01
    ping 10.2.1.3

    # Ping tới Spine02
    ping 10.2.1.4
    ```


- 