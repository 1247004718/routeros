#!/bin/bash
##auto install vnt on linux os
## author : qq 1247004718
green='\033[0;32m'
plain='\033[0m'
VERSION="v1.2.12"
CONF_DIR=/usr/local/etc
CONF_FILE=${CONF_DIR}/vnt_config.yaml
[[ ! -d ${CONF_DIR} ]] && mkdir -p ${CONF_DIR}
BIN_FILE=vnt-x86_64-unknown-linux-musl-$VERSION.tar.gz
wget -O /tmp/${BIN_FILE} https://github.com/vnt-dev/vnt/releases/download/$VERSION/vnt-x86_64-unknown-linux-musl-$VERSION.tar.gz >/dev/null 2>&1
tar -xf /tmp/${BIN_FILE} --overwrite -C /usr/bin && rm -f /tmp/${BIN_FILE} >/dev/null 2>&1

cat > ${CONF_FILE} <<EOF
token: pve_admin
password: IBdV6lyPfmyuoXV8eIgHZvWgvcT2eTjm+M41MXAQwmE=
server_encrypt: true
mtu: 1420
EOF
read -p "input Domain or public IP[y/N]:" yesorno
[ -z ${yesorno} ] && yesorno=N

if [[ "$yesorno" =~ ^[yY]$ ]]; then
	read -p "Domain or IP:" domain
	[ ! -z "${domain}" ] && echo "server_address: $domain:29872" >> ${CONF_FILE}
fi

echo "[Unit]
After=network.target nss-lookup.target

[Service]
User=root
WorkingDirectory=/root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=/usr/bin/vnt-cli -f ${CONF_FILE}
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=10
LimitNPROC=512
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/vnt.service
(
	set -x
	systemctl enable --now vnt.service >/dev/null 2>&1
	)
sleep 1 && echo -e "${green} vnt installing finished.${plain}"
sleep 2
systemctl status vnt.service
