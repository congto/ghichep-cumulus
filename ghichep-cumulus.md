# Ghi chép về Cumulus

## Cài đặt

- Cài thông qua VMware
 - Import lần lượt 4 máy từ file template down từ trang chủ.
 - Setup 04 NIC cho máy ảo đã Import, trong đó 01 interface là NAT, 03 interface còn lại sử dụng chế độ hostonly

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
    

### Cấu hình trên Spine01

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
    