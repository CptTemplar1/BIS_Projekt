Wymagania projektowe
OK  dostępy SSH
    dynamiczny protokoły routingu (OSPF, EIGRP)
OK  VLANy
    routing między vlanmi
    EtherChannel
    konfiguracja FHRP
OK  konfiguracja syslogu
OK  konfiguracja NTP
OK  konfiguracja AAA
OK  konfiguracja serwera DHCP
OK  dwie standardowe listy dostępu ACL
OK  dwie rozszerzone listy dostępu ACL
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

#NTP
#######
ntp server 191.168.1.3
service timestamps log datetime msec
no service timestamps debug datetime msec
#######

#CISCO IOS
#######
logging 191.168.1.3
#######

#TACACS+
#######
tacacs-server host 191.168.1.3
tacacs-server key cisco
aaa new-model
aaa authentication login default group tacacs+ local
line console 0
login authentication default
#######

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

#SSH
#######
ip domain-name r2
username cisco secret cisco
crypto key generate rsa general-keys modulus 1024
line vty 0 4
 transport input ssh
 login local
 exit
#######

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
enable
configure terminal

service password-encryption
hostname S0
enable password class

#SSH
#######
ip domain-name s0
username cisco secret cisco
crypto key generate rsa general-keys modulus 1024
line vty 0 15
 transport input ssh
 login local
 exit
#######

#NTP
#######
ntp server 191.168.1.3
service timestamps log datetime msec
no service timestamps debug datetime msec
#######

#CISCO IOS
#######
logging 191.168.1.3
#######

interface Vlan1
 ip address 191.168.1.2 255.255.255.0
 no shutdown
 exit

ip default-gateway 191.168.1.1

end
write memory

############################################################################################################
#Podsieć 2 - dwie standardowe listy ACL
#R3
enable
configure terminal

service password-encryption
hostname R3
enable password class

#ACL 10 - blokuje ruch przychodzący z PC2 (192.168.10.2)
access-list 10 deny 192.168.10.2
access-list 10 permit any

#ACL 20 - blokuje ruch wychodzący z routera do PC3 (192.168.20.3)
access-list 20 deny 192.168.20.3
access-list 20 permit any

#Przypisanie ACL do interfejsów
#######
interface GigabitEthernet0/0
 ip address 192.168.10.1 255.255.255.0
 ip access-group 10 in
 no shutdown
 exit

interface GigabitEthernet0/1
 ip address 192.168.20.1 255.255.255.0
 ip access-group 20 out
 no shutdown
 exit
#######

interface Serial0/3/0
 ip address 4.0.0.2 255.0.0.0
 no shutdown
 exit

end
write memory


############################################################################################################
#Podsieć 3 - dwie rozszerzone listy ACL
#R4
enable
configure terminal

service password-encryption
hostname R4
enable password class

#ACL 110 – zablokuj HTTP z PC4 w kierunku "świata" (czyli dalej przez R0)
access-list 110 deny tcp host 193.168.10.4 any eq 80
access-list 110 permit ip any any

#ACL 120 – zablokuj Telnet z PC5 do dowolnych hostów w tej samej podsieci (193.168.20.0/24)
access-list 120 deny tcp host 193.168.20.5 193.168.20.0 0.0.0.255 eq 23
access-list 120 permit ip any any

#Przypisanie list ACL do interfejsów
#######
interface GigabitEthernet0/0
 ip address 193.168.10.1 255.255.255.0
 ip access-group 110 in
 no shutdown
 exit

interface GigabitEthernet0/1
 ip address 193.168.20.1 255.255.255.0
 ip access-group 120 in
 no shutdown
 exit
#######

interface Serial0/3/0
 ip address 5.0.0.2 255.0.0.0
 no shutdown
 exit

end
write memory


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

service password-encryption
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
ip default-gateway 197.168.1.1

end
write memory