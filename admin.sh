#!/bin/bash

ifconfig eth0 192.168.137.2 netmask 255.255.255.0 up

FIREWALL(){
while true
do
FW=$(dialog --menu "Configuration du firewall" 20 35 15 \ 
1 "Autoriser les connexions" \ 
2 "Bloquer les connexions" \ 
3 "Retour" --stdout)

FWINIT=$( iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 80 --sport 1024:65535 -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 433 --sport 1024:65535 -j ACCEPT
)

echo $FW
echo $FWINIT
case $FW in
    1) iptables -A INPUT -i eth0 -m state --state RELATED, ESTABLISHED -j ACCEPT
        iptables -A OUTPUT -i eth0 -m state --state RELATED, ESTABLISHED -j ACCEPT;;
    2) iptables -A INPUT -i eth0 -m state --state RELATED, ESTABLISHED -j REJECT
        iptables -A OUTPUT -i eth0 -m state --state RELATED, ESTABLISHED -j REJECT;;
    3) MAINMENU;;
    *) echo 'Option invalide';;
esac
done
}

MAINMENU(){
while true
do
MENU=$(dialog --menu "Demarrage des servires" 20 35 15 \ 
1 "Configuration du Firewall" \ 
2 "Demarrage du service proxy Squid" \ 
3 "Demarrage de l'IDS Snort" \ 
4 "Quitter la session" --stdout)

echo $MENU
case $MENU in
    1) FIREWALL;;
    2) service squid start;;
    3) snort -A console -i eth0 -u snort -c /etc/snort/snort.conf;;
    4) exit;;
    *) echo 'Option invalide';;
esac
done
}

while true
do
MAINMENU
done