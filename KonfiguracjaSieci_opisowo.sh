Wymagania projektowe
    dostępy SSH
    dynamiczny protokoły routingu (OSPF, EIGRP)
OK  VLANy
    routing między vlanmi
    EtherChannel
    konfiguracja FHRP
    konfiguracja syslogu
    konfiguracja NTP
    konfiguracja AAA
    konfiguracja serwera DHCP
    dwie standardowe listy dostępu ACL
    dwie rozszerzone listy dostępu ACL
    zabezpieczenia przez atakami MAC
    zabezpieczenia przez atakami VLAN
    zabezpieczenia przez atakami DHCP
    zabezpieczenia przez atakami STP
    konfiguracja poziomów dostępowych na urządzeniach sieciowych




############################################################################################################
############################################################################################################
SCHEMAT SIECI
############################################################################################################



############################################################################################################
############################################################################################################
KONFIGURACJA URZĄDZEŃ SIECIOWYCH
############################################################################################################
#Centrum
#R0
enable
configure terminal

service password-encryption
hostname R0
enable password class
username cisco secret cisco
ip domain-name r0

interface Serial0/0/0
 ip address 1.0.0.2 255.0.0.0
 no shutdown
 exit

interface Serial0/0/1
 ip address 3.0.0.2 255.0.0.0
 no shutdown
 exit

 interface Serial0/1/0
 ip address 4.0.0.1 255.0.0.0
 no shutdown
 exit

 interface Serial0/1/1
 ip address 5.0.0.1 255.0.0.0
 no shutdown
 exit

interface GigabitEthernet0/0
 ip address 191.168.1.1 255.255.255.0
 no shutdown
 exit

#VLANy
#######
interface GigabitEthernet0/1
 no ip address
 no shutdown
 exit

interface GigabitEthernet0/0.10
 encapsulation dot1Q 10
 ip address 197.168.1.1 255.255.255.0
 no shutdown
 exit

interface GigabitEthernet0/0.20
 encapsulation dot1Q 20
 ip address 197.168.2.1 255.255.255.0
 no shutdown
 exit

interface GigabitEthernet0/0.30
 encapsulation dot1Q 30
 ip address 197.168.3.1 255.255.255.0
 no shutdown
 exit
#######

end
write memory


#R1
enable
configure terminal

service password-encryption
hostname R1
enable password class
username cisco secret cisco
ip domain-name r1

interface Serial0/0/0
 ip address 1.0.0.1 255.0.0.0
 no shutdown
 exit

interface Serial0/0/1
 ip address 2.0.0.1 255.0.0.0
 no shutdown
 exit

interface GigabitEthernet0/0
 ip address 194.168.1.1 255.255.255.0
 no shutdown
 exit

end
write memory


#R2
enable
configure terminal

service password-encryption
hostname R2
enable password class
username cisco secret cisco
ip domain-name r2

interface Serial0/0/0
 ip address 2.0.0.2 255.0.0.0
 no shutdown
 exit

interface Serial0/0/1
 ip address 3.0.0.1 255.0.0.0
 no shutdown
 exit

interface GigabitEthernet0/1
 ip address 196.168.1.1 255.255.255.0

end
write memory


############################################################################################################
#Podsieć 1 - DHCP, SSH, NTP, CISCO IOS, TACACS+
#S0



############################################################################################################
#Podsieć 2 - dwie standardowe listy ACL
#R3


#S1


#S2


############################################################################################################
#Podsieć 3 - dwie rozszerzone listy ACL
#R4


#S3


#S4


############################################################################################################
#Podsieć 4 - zabezpieczenia przez atakami STP
#Central


#S5


#S6


#S7


#S8


############################################################################################################
#Podsieć 5 - FHRP (HSRP)
#S9


#S10


############################################################################################################
#Podsieć 6 - EtherChannel
#S11


#S12


#S13


############################################################################################################
#Podsieć 7 - VLANy, routing między VLANami, zabezpieczenia przez atakami VLAN
#S14
enable
configure terminal

hostname S1
enable password class

interface FastEthernet0/1
 switchport mode trunk
 no shutdown
 exit

interface range FastEthernet0/2-3
 switchport mode access
 switchport access vlan 10
 no shutdown
 exit

interface range FastEthernet0/4-5
 switchport mode access
 switchport access vlan 20
 no shutdown
 exit

interface range FastEthernet0/6-7
 switchport mode access
 switchport access vlan 30
 no shutdown
 exit

#główny vlan do zarządzania switchem
interface Vlan1
 ip address 197.168.1.10 255.255.255.0
 no shutdown
 exit

#brama domyślna dla switcha 
ip default-gateway 192.168.1.1

end
write memory