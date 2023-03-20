# clearssh Credits: Andley302
Basic script to configure vpn over ssh

sudo su;

apt update && apt upgrade -y && apt install wget -y && wget https://raw.githubusercontent.com/KRATOSvpn/clear-ssh/main/installer.sh && chmod +x installer.sh && ./installer.sh;
