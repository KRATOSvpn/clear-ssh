#!/bin/bash
clear
fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "  \033[1;33mAGUARDE \033[1;37m- \033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "  \033[1;33mAGUARDE \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}
echo "REINICIANDO DNSTT"
fun_start () {
screen -ls | grep dnstt | cut -d. -f1 | awk '{print $1}' | xargs kill
sleep 2

#NS
nameserver='1234'

cd /root && screen -dmS dnstt ./dnstt-server -udp :53 -privkey-file server.key $nameserver 127.0.0.1:80
sleep 1
}
fun_bar 'fun_start'
sleep 2
echo ""
echo "  DNSTT Reiniciado Com Sucesso! [✔]"
