Wymagania projektowe
    OK  dostępy SSH
    OK  dynamiczny protokoły routingu (OSPF, EIGRP)
    OK  VLANy
    OK  routing między vlanmi
    OK  EtherChannel
    OK  konfiguracja FHRP
    OK  konfiguracja syslogu
    OK  konfiguracja NTP
    OK  konfiguracja AAA
    OK  konfiguracja serwera DHCP
    OK  dwie standardowe listy dostępu ACL
    OK  dwie rozszerzone listy dostępu ACL
    OK  zabezpieczenia przez atakami MAC
    OK  zabezpieczenia przez atakami VLAN
    OK  zabezpieczenia przez atakami DHCP
    OK  zabezpieczenia przez atakami STP
    OK  konfiguracja poziomów dostępowych na urządzeniach sieciowych


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
ip domain-name r0

! #POZIOMY DOSTĘPU
! #######
! #Wymuszenie logowania użytkownika
line console 0
 login local
 exit

username admin privilege 15 secret admin123
username technik privilege 10 secret technik123
username junior privilege 5 secret junior123

! #Dostępne polecenia dla poziomu 5 (junior)
privilege exec level 5 ping
privilege exec level 5 show ip interface brief
privilege exec level 5 show version

! #Dostępne polecenia dla poziomu 10 (technik)
privilege exec level 10 show running-config
privilege exec level 10 show interfaces
privilege exec level 10 configure terminal
! #######

! #NTP
! #######
ntp server 191.168.1.3
service timestamps log datetime msec
no service timestamps debug datetime msec
! #######

! #CISCO IOS
! #######
logging 191.168.1.3
! #######

! #TACACS+
! #######
tacacs-server host 191.168.1.3
tacacs-server key cisco
aaa new-model
aaa authentication login default group tacacs+ local
line console 0
login authentication default
! #######

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

! #VLANy
! #######
interface GigabitEthernet0/1
 no ip address
 no shutdown
 exit

interface GigabitEthernet0/1.10
 encapsulation dot1Q 10
 ip address 197.168.1.1 255.255.255.0
 no shutdown
 exit

interface GigabitEthernet0/1.20
 encapsulation dot1Q 20
 ip address 197.168.2.1 255.255.255.0
 no shutdown
 exit

interface GigabitEthernet0/1.30
 encapsulation dot1Q 30
 ip address 197.168.3.1 255.255.255.0
 no shutdown
 exit
! #######

! #ROUTING OSPF
! #######
router ospf 1
 router-id 0.0.0.1
 network 1.0.0.0 0.255.255.255 area 0
 network 3.0.0.0 0.255.255.255 area 0
 network 4.0.0.0 0.255.255.255 area 0
 network 5.0.0.0 0.255.255.255 area 0
 network 191.168.1.0 0.0.0.255 area 0
 network 197.168.0.0 0.0.255.255 area 0
 exit
! #######

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

! #FHRP
! #######
interface GigabitEthernet0/1
 ip address 195.168.1.1 255.255.255.0
 standby version 2
 standby 1 ip 195.168.1.254
 standby 1 priority 150
 standby 1 preempt
 no shutdown
 exit
! #######

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

! #ROUTING OSPF
! #######
router ospf 1
 router-id 1.1.1.1
 network 1.0.0.0 0.255.255.255 area 0
 network 2.0.0.0 0.255.255.255 area 0
 network 194.168.1.0 0.0.0.255 area 0
 network 195.168.1.0 0.0.0.255 area 0
 exit
! #######

end
write memory


#R2
enable
configure terminal

service password-encryption
hostname R2
enable password class

! #SSH
! #######
ip domain-name r2
username cisco secret cisco
crypto key generate rsa general-keys modulus 1024
line vty 0 4
 transport input ssh
 login local
 exit
! #######

! #FHRP
! #######
interface GigabitEthernet0/0
 ip address 195.168.1.2 255.255.255.0
 standby version 2
 standby 1 ip 195.168.1.254
 no shutdown
 exit
! #######

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
 no shutdown
 exit

! #ROUTING OSPF
! #######
router ospf 1
 router-id 2.2.2.2
 network 2.0.0.0 0.255.255.255 area 0
 network 3.0.0.0 0.255.255.255 area 0
 network 195.168.1.0 0.0.0.255 area 0
 network 196.168.1.0 0.0.0.255 area 0
 exit
! #######

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

! #POZIOMY DOSTĘPU
! #######
! #Wymuszenie logowania użytkownika
line console 0
 login local
 exit

username admin privilege 15 secret admin123
username technik privilege 10 secret technik123
username junior privilege 5 secret junior123

! #Dostępne polecenia dla poziomu 5 (junior)
privilege exec level 5 ping
privilege exec level 5 show ip interface brief
privilege exec level 5 show version

! #Dostępne polecenia dla poziomu 10 (technik)
privilege exec level 10 show running-config
privilege exec level 10 show interfaces
privilege exec level 10 configure terminal
! #######

! #SSH
! #######
ip domain-name s0
crypto key generate rsa general-keys modulus 1024
line vty 0 15
 privilege level 1
 transport input ssh
 login local
 exit
! #######

! #NTP
! #######
ntp server 191.168.1.3
service timestamps log datetime msec
no service timestamps debug datetime msec
! #######

! #CISCO IOS
! #######
logging 191.168.1.3
! #######

interface Vlan1
 ip address 191.168.1.2 255.255.255.0
 no shutdown
 exit

ip default-gateway 191.168.1.1

! #ZABEZPIECZENIA PRZED ATAKAMI DHCP
! #######
! #Włączenie DHCP snooping globalnie
ip dhcp snooping

! #Włączenie DHCP snooping dla VLAN 1
ip dhcp snooping vlan 1

! #Port połączony z serwerem DHCP (Server0 na Fa0/3) musi być zaufany
interface FastEthernet0/3
 ip dhcp snooping trust
 exit

! #Ogranicz liczbę pakietów DHCP z niezaufanych portów (ochrona przed floodingiem)
interface range FastEthernet0/1, FastEthernet0/2, FastEthernet0/4
 ip dhcp snooping limit rate 5
 exit
! #######

! #ZABEZPIECZENIA PRZED ATAKAMI MAC
! #######
interface range FastEthernet0/2, FastEthernet0/4
 switchport mode access
 switchport port-security
 switchport port-security maximum 1
 switchport port-security violation restrict
 switchport port-security mac-address sticky
 exit
! #######

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

! #ACL 10 - blokuje ruch przychodzący z PC2 (192.168.10.2)
access-list 10 deny 192.168.10.2
access-list 10 permit any

! #ACL 20 - blokuje cały ruch wychodzący z routera na interfejsie
access-list 20 deny any

! #Przypisanie ACL do interfejsów
! #######
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
! #######

interface Serial0/3/0
 ip address 4.0.0.2 255.0.0.0
 no shutdown
 exit

! #ROUTING OSPF
! #######
router ospf 1
 router-id 3.3.3.3
 network 4.0.0.0 0.255.255.255 area 0
 network 192.168.10.0 0.0.0.255 area 0
 network 192.168.20.0 0.0.0.255 area 0
 exit
! #######

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

! #ACL 110 - zablokuj HTTP z PC4 w kierunku "świata" (czyli dalej przez R0)
access-list 110 deny tcp host 193.168.10.4 any eq 80
access-list 110 permit ip any any

! #ACL 120 - zablokuj Telnet z PC5 do dowolnych hostów w tej samej podsieci (193.168.20.0/24)
access-list 120 deny tcp host 193.168.20.5 193.168.20.0 0.0.0.255 eq 23
access-list 120 permit ip any any

! #Przypisanie list ACL do interfejsów
! #######
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
! #######

interface Serial0/3/0
 ip address 5.0.0.2 255.0.0.0
 no shutdown
 exit

! #ROUTING OSPF
! #######
router ospf 1
 router-id 4.4.4.4
 network 5.0.0.0 0.255.255.255 area 0
 network 193.168.10.0 0.0.0.255 area 0
 network 193.168.20.0 0.0.0.255 area 0
 exit
! #######

end
write memory


############################################################################################################
#Podsieć 4 - zabezpieczenia przez atakami STP
#Central
enable
configure terminal

service password-encryption
hostname Central
enable password class

spanning-tree mode pvst
spanning-tree vlan 1 root primary

end
write memory

#S5
enable
configure terminal

service password-encryption
hostname S5
enable password class

spanning-tree mode pvst
spanning-tree vlan 1 root secondary

interface range FastEthernet0/23 - 24
 spanning-tree guard root

end
write memory


#S6
enable
configure terminal

service password-encryption
hostname S6
enable password class

interface range FastEthernet0/23 - 24
 spanning-tree guard root

end
write memory


#S7
enable
configure terminal

service password-encryption
hostname S7
enable password class

interface range FastEthernet0/1 - 4
 spanning-tree portfast
 spanning-tree bpduguard enable

end
write memory


#S8
enable
configure terminal

service password-encryption
hostname S8
enable password class

interface range FastEthernet0/1 - 4
 spanning-tree portfast
 spanning-tree bpduguard enable

end
write memory


############################################################################################################
#Podsieć 5 - FHRP (HSRP)
#S9
enable
configure terminal

service password-encryption
hostname S9
enable password class

ip default-gateway 195.168.1.254

end
write memory


#S10
enable
configure terminal

service password-encryption
hostname S10
enable password class

ip default-gateway 195.168.1.254

end
write memory

############################################################################################################
#Podsieć 6 - EtherChannel (do weryfikacji)
#S11
enable
config terminal

service password-encryption
hostname S11
enable password class

interface range FastEthernet0/1 - 2
 switchport mode trunk
 channel-protocol pagp
 channel-group 1 mode desirable
 no shutdown

interface port-channel 1
 switchport mode trunk

interface range FastEthernet0/3 - 4
 switchport mode trunk
 channel-protocol lacp
 channel-group 2 mode active
 no shutdown

interface port-channel 2
 switchport mode trunk

spanning-tree vlan 1 root primary

end
write memory

#S12
enable
config terminal

service password-encryption
hostname S12
enable password class

interface range FastEthernet0/3 - 4
 switchport mode trunk
 channel-protocol lacp
 channel-group 2 mode active
 no shutdown

interface port-channel 2
 switchport mode trunk

interface range FastEthernet0/5 - 6
 switchport mode trunk
 channel-protocol lacp
 channel-group 3 mode passive
 no shutdown

interface port-channel 3
 switchport mode trunk

end
write memory

#S13
enable
config terminal

service password-encryption
hostname S13
enable password class

interface range FastEthernet0/1 - 2
 switchport mode trunk
 channel-protocol pagp
 channel-group 1 mode desirable
 no shutdown

interface port-channel 1
 switchport mode trunk

interface range FastEthernet0/5 - 6
 switchport mode trunk
 channel-protocol lacp
 channel-group 3 mode active
 no shutdown

interface port-channel 3
 switchport mode trunk

end
write memory

############################################################################################################
#Podsieć 7 - VLANy, routing między VLANami, zabezpieczenia przez atakami VLAN
#S14
enable
configure terminal

service password-encryption
hostname S14
enable password class

interface range FastEthernet0/2 - 3
 switchport mode access
 switchport access vlan 10
 no shutdown
 exit

interface range FastEthernet0/4 - 5
 switchport mode access
 switchport access vlan 20
 no shutdown
 exit

interface range FastEthernet0/6 - 7
 switchport mode access
 switchport access vlan 30
 no shutdown
 exit

! #główny vlan do zarządzania switchem
interface Vlan1
 ip address 197.168.1.10 255.255.255.0
 no shutdown
 exit

! #brama domyślna dla switcha 
ip default-gateway 197.168.1.1

! #ZABEZPIECZENIA PRZED ATAKAMI VLAN
! #######
! #Utworzenie VLANu 999 do izolacji nieużywanych portów
vlan 999
 name VLAN_UNUSED
exit

! #Wyłączanie nieużywanych portów
interface range Fa0/8 - 24
 switchport mode access
 switchport access vlan 999
 shutdown
exit

! #Zabezpieczenie portów dostępowych
interface range Fa0/2 - 7
 switchport mode access
 switchport nonegotiate
 switchport port-security
 switchport port-security maximum 1
 switchport port-security violation restrict
 switchport port-security mac-address sticky
exit

! #Port trunk
interface Fa0/1
 switchport mode trunk
 switchport nonegotiate
 no shutdown
 exit
! #######

end
write memory