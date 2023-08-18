#!/bin/bash
#INSTALADOR DEPENDENCIAS ONEVPS
#sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
#sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
#sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
#sudo systemctl stop systemd-resolved;
#sudo systemctl disable systemd-resolved;
#sudo systemctl mask systemd-resolved;
#sudo systemctl unmask systemd-resolved;
#sudo systemctl enable systemd-resolved && sudo systemctl start systemd-resolved;
clear;
echo "ClearSSH - Iniciando instalação...";
sleep 5;
clear;
apt install screen iptables cron curl certbot git screen htop net-tools nload speedtest-cli ipset unattended-upgrades whois -y;
apt install dos2unix -y && apt install unzip && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/sync/sync.zip && unzip sync.zip && chmod +x *.sh && dos2unix *.sh && rm -rf sync.zip;
clear;
echo "Instalando DKMS (Anti-torrent)...";
apt purge xtables* -y;
apt install make -y;
apt install dkms -y;
apt install linux-headers-$(uname -r);
cd /root;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/iptables/xtables-addons-common_3.18-1_amd64.deb;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/iptables/xtables-addons-dkms_3.18-1_all.deb;
dpkg -i *.deb;
apt --fix-broken install;
rm -rf *.deb;
clear;
echo "Banner SSH...";
sleep 5
cd /etc;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/ssh/bannerssh;

echo "Custumizar BannerSSH manualmente (se vc selecionar N ira usar o editor de banner do SSHPLUS) [s/n]:"
read EDITbanner

case $EDITbanner in 
    "s")
        read -p "Digite sua msg custumizada para o BannerSSH: (ex: <br> <br> <strong><font color='#D84315'>Olá Mundo</font></strong> <br>)" MSG
        echo  $MSG > /etc/bannerssh
	service ssh restart > /dev/null 2>&1 && service dropbear restart > /dev/null 2>&1
        echo -e "\n\033[1;32mBANNER DEFINIDO !\033[0m"
    ;;
    
    "n")
        cd /bin && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/banner && chmod 777 banner && banner;
    ;;
    "N")
        cd /bin && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/banner && chmod 777 banner && banner;
    ;;
    *)
        echo  "Opção inválida."
    ;;
esac

cd /root;
clear;
echo "Instalando Dropbear...";
sleep 5;
porta=8000;
apt install dropbear -y;
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear >/dev/null 2>&1
sed -i "s/DROPBEAR_PORT=22/DROPBEAR_PORT=$porta/g" /etc/default/dropbear >/dev/null 2>&1
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 7777"/g' /etc/default/dropbear >/dev/null 2>&1
sed -i 's/DROPBEAR_BANNER=""//g' /etc/default/dropbear >/dev/null 2>&1
sed -i "$ a DROPBEAR_BANNER=\"/etc/bannerssh\"" /etc/default/dropbear;
grep -v "^PasswordAuthentication yes" /etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
grep -v "^PermitTunnel yes" /etc/ssh/sshd_config >/tmp/ssh && mv /tmp/ssh /etc/ssh/sshd_config
echo "PermitTunnel yes" >>/etc/ssh/sshd_config
echo "/bin/false" >>/etc/shells
service dropbear restart;
clear;
echo "Instalando stunnel4...";
sleep 5;
apt install stunnel4 -y;
cd /etc/stunnel;
rm -rf stunnel.conf;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/stunnel/stunnel.conf;
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
clear;
echo "Verificando certificados stunnel...";
sleep 5;
if [ -e cert.pem ]
then
    echo "Certificado já está instalado. Continuando...."
else
    echo "Baixando certificados..."
    wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/stunnel/cert.pem
	wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/stunnel/key.pem
fi
service stunnel4 restart;
clear;
echo "API Onlines (Apache2)...";
sleep 5;
apt install apache2 -y;
cd /etc/apache2 && rm -rf ports.conf;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/onlines-api/ports.conf;

echo "Atualmente o apache esta rodando na porta 8877, deseja alterar esta porta? [s/N]:"
read EDIT

case $EDIT in 
    "s")
     #NODE
	 read -p "Insira a porta que deseja usar no apache [ Portas ja utilizadas por padrão DROP(8000, 7777), SSL(443, 2053, 2083) ]: " PORTA
	 
	 if [[ "$resposta" = '' ]]; then
	 echo "Você não digitou uma porta válida o apache continuará na porta 8877, você pode alterar depois em /etc/apache2/ports.conf"
	 sleep 5;
	 else
	 sed -i 's/Listen 8877/Listen $PORTA/g' ports.conf
	 fi
    ;;
esac


service apache2 restart;
mkdir /var/www/html/server;
clear;
echo "Regras iptables...";
sleep 5;
cd /root && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/onlines-api/onlines && chmod +x onlines && mv onlines /bin/onlines;
cd /root && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/onlines-api/onlineapp.sh && chmod +x onlineapp.sh && ./onlineapp.sh;
cd /root && rm -rf iptables* && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/iptables/iptables_reset_53 && mv iptables_reset_53 iptables.sh && chmod +x iptables.sh && ./iptables.sh;

##BAIXA E COMPILA DNSTT
clear
echo ""
	read -p "Baixar e compilar DNSTT? [s/n]: " -e -i n resposta
	if [[ "$resposta" = 's' ]]; then
clear;
echo "Preparando DNSTT...";
sleep 5;
cd /usr/local;
wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz;
tar xvf go1.16.2.linux-amd64.tar.gz;
export GOROOT=/usr/local/go;
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH;
cd /root;
git clone https://www.bamsoftware.com/git/dnstt.git;
cd /root/dnstt/dnstt-server;
go build;
cd /root/dnstt/dnstt-server && cp dnstt-server /root/dnstt-server;
cd /root;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/dnstt/server.key;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/dnstt/server.pub;

##
##ENABLE RC.LOCAL
set_ns () {
cd /etc;
mv rc.local rc.local.bkp;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/rc.local;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/restartdns.sh;
chmod +x /etc/rc.local;
echo -ne "\033[1;32m INFORME SEU NS (NAMESERVER)\033[1;37m: "; read nameserver
sed -i "s;1234;$nameserver;g" /etc/rc.local > /dev/null 2>&1
sed -i "s;1234;$nameserver;g" restartdns.sh > /dev/null 2>&1
systemctl enable rc-local;
systemctl start rc-local;
chmod +x restartdns.sh
mv restartdns.sh /bin/restartdns
}
clear;
echo "Aguarde...";
sleep 5;
echo "Deseja instalar o DNSTT? (s/n)"
read CONFIRMA

case $CONFIRMA in 
    "s")
        set_ns
    ;;

    "n")
                 
    ;;

    *)
        echo  "Opção inválida."
    ;;
esac
fi
#LIMITADOR DE PROCESSOS
clear;
echo "Aumentando limite de processos do sistema...";
sleep 5;
cd /etc/security;
mv limits.conf limits.conf.bak;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/limits.conf && chmod +x limits.conf;
#CRONTAB
echo "Configurando crontab...";
sleep 5;
cd /etc;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/autostart;
chmod +x autostart;
crontab -r >/dev/null 2>&1
(
	crontab -l 2>/dev/null
	echo "@reboot /etc/autostart"
	echo "* * * * * /etc/autostart"
	echo "*/1 * * * * /root/onlineapp.sh"	
	echo "* * * * * /root/restartdrop.sh"
	echo "0 */6 * * * restartdns"
	echo "*/30 * * * * /root/clear_caches.sh"
	echo "0 */6 * * * /root/system_updates.sh"
	
) | crontab -
service cron reload;
#echo "*/6 * * * * systemctl restart systemd-resolved.service"
#echo "* * * * * /root/restartdrop.sh"	
#echo "0 */12 * * * /sbin/reboot"
clear;
echo "Instalando fast...";
cd /root
sleep 5;
wget https://github.com/ddo/fast/releases/download/v0.0.4/fast_linux_amd64;
sudo install fast_linux_amd64 /usr/local/bin/fast;
clear;
echo "Aguarde...";



function install_proxy(){
echo ""
	read -p "Deseja instalar algum/mais algum proxy? [s/n]: " -e -i n resposta
	if [[ "$resposta" = 's' ]]; then
	
	install_qual_proxy
	
	fi
}


function install_qual_proxy(){


sleep 5;
echo "Qual proxy você deseja instalar?"
echo "1) proxy NODE [Status 101]"
echo "2) PYTHON [Status 200]"
echo "3) GO [Status 101 OK]"
echo "4) Proxy DT [Status 101]"
echo "5) Proxy X86 Crazy [Status 101]"
read CONFIRMA

case $CONFIRMA in 
    "1")
     #NODE
	 read -p "Insira a porta que deseja usar neste proxy [ Portas ja utilizadas por padrão DROP(8000, 7777), SSL(443, 2053, 2083) ]: " PORT
	 
    clear;
    echo "Instalando NodeJS...";
    sleep 5; 
    cd ~
    curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
    sudo apt install nodejs -y;
    cd /root;
    clear;
    echo "Instalando Proxy...";
    sleep 5;
    wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/wsproxy/proxy3.js;
    clear;
    echo -e "netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS nodews node /root/proxy3.js" >> /etc/autostart;
    netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS nodews node /root/proxy3.js
              install_proxy   
    ;;

    "2")
    #python
	 read -p "Insira a porta que deseja usar neste proxy: " PORT
	 
    cd /root;
    clear;
    echo "Instalando Python...";
    sleep 5; 
    apt install python python3 -y;
    clear;
    wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/wsproxy/wsproxy.py
    wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/wsproxy/antcrashws.sh -O /bin/antcrashws.sh > /dev/null 2>&1
    chmod +x /bin/antcrashws.sh;
    echo -e "netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS wsproxy80 antcrashws.sh $PORT" >> /etc/autostart;
    netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS wsproxy80 antcrashws.sh $PORT
              install_proxy   
    ;;
    "3")
    #proxygo
	 read -p "Insira a porta que deseja usar neste proxy: " PORT
	 
    cd /root;
    clear;
    echo "Instalando Proxy Go...";
    sleep 5; 
    clear;
    wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/wsproxy/sshProxy -O /bin/sshProxy > /dev/null 2>&1
    chmod +x /bin/sshProxy;
    echo -e "netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS goproxy sshProxy -addr :$PORT -dstAddr 127.0.0.1:7777 -custom_handshake "\"200 "\" " >> /etc/autostart;
    netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS goproxy sshProxy -addr :$PORT -dstAddr 127.0.0.1:7777 -custom_handshake "200 "
              install_proxy        
    ;;
    "4")
    #proxygo
	 read -p "Insira a porta que deseja usar neste proxy: " PORT
	 
    cd /root;
    clear;
    echo "Instalando Proxy DT...";
    sleep 5; 
    clear;
    rm -f /usr/bin/proxy
    curl -s -L -o /usr/bin/proxy https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/wsproxy/proxyDT
    chmod +x /usr/bin/proxy
    clear
    echo -e "netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS proxyDT /usr/bin/proxy --port $PORT --http --ssh-only --response "\"WebSocket"\"" >> /etc/autostart;
    netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS proxyDT /usr/bin/proxy --port $PORT --http --ssh-only --response "WebSocket"
              install_proxy        
    ;;
    "5")
    #proxygo
	 read -p "Insira a porta que deseja usar neste proxy: " PORT
	 
    cd /root;
    clear;
    echo "Instalando Proxy X86 Crazy...";
    sleep 5; 
    clear;
    curl -s -L -o WebSocket86.zip https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/wsproxy/WebSocket86.zip
    apt install unzip -y
    unzip WebSocket86.zip
    rm WebSocket86.zip
    chmod +x WebSocket86
    apt install dos2unix screen -y
    clear
    echo -e "netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS novoWS WebSocket86 -proxy_port 0.0.0.0:$PORT -msg="\"WebSocket"\"" >> /etc/autostart;
    netstat -tlpn | grep -w $PORT > /dev/null || screen -dmS novoWS WebSocket86 -proxy_port 0.0.0.0:$PORT -msg="WebSocket"
              install_proxy        
    ;;

    *)
        echo  "Opção inválida."
    ;;
esac

}
install_proxy 



#BADVPN
clear;
echo "Aguarde...";
sleep 5;
clear;
echo "Deseja instalar o badvpn? (s/n)"
read CONFIRMA

case $CONFIRMA in 
    "s")
        cd /root && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/badvpn/badvpn-x.sh && chmod +x badvpn-x.sh && ./badvpn-x.sh;
    ;;

    "n")
                 
    ;;

    *)
        echo  "Opção inválida."
    ;;
esac
##FIM
cd /root;
clear;
wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/tcp_weaker.sh && chmod +x tcp_weaker.sh && ./tcp_weaker.sh;
sleep 5;
clear;
echo "Reiniciando DNSTT (Caso tenha sido instalado)...";
sleep 5;
restartdns;
clear;
echo "Ferramentas de otimização....";
sleep 5;
cd /root && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/others/consumo && chmod +x consumo && mv consumo /bin/consumo;
apt autoremove -y && apt -f install -y && apt autoclean -y;
clear;
echo "Finalizando...";
echo "Banner /etc/bannerssh" >> /etc/ssh/sshd_config
sleep 5;
service dropbear stop;
service dropbear start;
rm -rf installer.sh;
rm -rf fast_linux_amd64;
clear;
echo "FIM!";
sleep 5;
