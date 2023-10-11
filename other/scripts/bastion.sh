#!/bin/bash
cp /etc/ssh/sshd_config  /etc/ssh/sshd_config_backup 
echo "Port 49160" >> /etc/ssh/sshd_config 
yes | ufw enable 
ufw allow 49160/tcp
systemctl restart sshd 
systemctl restart ufw