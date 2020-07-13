#! /bin/bash

mkdir /root/vless
mv /root/ws* /root/vless
mv /root/tcp* /root/vless
mv /root/hap* /root/vless

v2ray_install() {
	timedatectl set-timezone Asia/Shanghai 
	wget https://install.direct/go.sh
	chmod +x go.sh
	./go.sh &>/dev/null
	rm -rf /etc/v2ray/config.json
}

uuid1=`cat /proc/sys/kernel/random/uuid` &>/dev/null

vless_download() {
	cd vless
	wget https://github.com/rprx/v2ray-vless/releases/download/clean2/v2ray-linux-64.zip
	unzip v2ray-linux-64.zip
	mv /usr/bin/v2ray/* /opt
	cp -r * /usr/bin/v2ray/
	cd /root/
}

read -p "请输入您绑定的域名(请检查清楚！如输入有误，请在安装完成后在/etc/nginx/conf.d/文件夹中修改配置文件)": dname

change_json() {
	sed -ri '10s/.*/            "id":"'$uuid1'",/' /root/vless/ws.json
	sed -ri '10s/.*/                        "id":"'$uuid1'",/' /root/vless/tcp.json
	sed -ri '10s/.*/              "id":"'$uuid1'",/' /root/vless/wsv.json
	sed -ri '10s/.*/                        "id":"'$uuid1'",/' /root/vless/tcpv.json 
	sed -i 's/example.com/'$dname'/g' /root/vless/tcp.conf
	sed -i 's/example.com/'$dname'/g' /root/vless/ws.conf
}

acme_install() {
	apt-get install openssl cron socat curl -y
	curl  https://get.acme.sh | sh
	~/.acme.sh/acme.sh --issue -d $dname --standalone --keylength ec-256 --force
	~/.acme.sh/acme.sh --installcert -d $dname --ecc \
                          --fullchain-file /etc/v2ray/v2ray.crt \
                          --key-file /etc/v2ray/v2ray.key
	mkdir /etc/ssl/private
	cat /etc/v2ray/v2ray.crt /etc/v2ray/v2ray.key > /etc/ssl/private/v2ray.pem
}
#vless_ws() {
#	cp ws.json /etc/v2ray/config.json
#}

haproxy_install() {
	apt install haproxy -y
	rm -rf /etc/haproxy/haproxy.cfg
	sed -i 's/example.com/v2ray/g' /root/vless/haproxy.cfg
	cp /root/vless/haproxy.cfg /etc/haproxy/haproxy.cfg
}

uprint() {
	echo ""
	echo "你的uuid为：$uuid1"
}

pathprint() {
	echo "ws路径：/ray"
}
clear
cat <<-EOF
           #############################
            #        请选择            #
            # 1、vless+ws+tls+web      #
            # 2、vless+tcp+tls+web     #
            # 3、vmess+ws+tls+web      #
            # 4、vmess+tcp+tls+web     #
            ############################
EOF

read -p "请输入您的选择:" choice
case "$choice" in
1)
	v2ray_install
	vless_download
	change_json
	acme_install
	apt install nginx -y
	cp /root/vless/wsv.json /etc/v2ray/config.json
	cp /root/vless/ws.conf /etc/nginx/conf.d/ws.conf
	systemctl restart v2ray
	systemctl restart nginx
	clear
	uprint
	pathprint
	;;
2)
	v2ray_install
	vless_download
	change_json
	acme_install
	apt install nginx -y
	haproxy_install
	cp /root/vless/tcpv.json /etc/v2ray/config.json
	cp /root/vless/tcp.conf /etc/nginx/conf.d/tcp.conf
	systemctl restart v2ray
	systemctl restart nginx
	clear
	uprint
	;;
3)
	v2ray_install
	change_json
	acme_install
	apt install nginx -y
	haproxy_install
	cp /root/vless/ws.json /etc/v2ray/config.json
	cp /root/vless/ws.conf /etc/nginx/conf.d/ws.conf
	systemctl restart v2ray
	systemctl restart nginx
	clear
        uprint
	pathprint
	;;
4)
	v2ray_install
        change_json
	acme_install
        apt install nginx -y
	haproxy_install
	cp /root/vless/tcp.json /etc/v2ray/config.json
        cp /root/vless/tcp.conf /etc/nginx/conf.d/tcp.conf
        systemctl restart v2ray
        systemctl restart nginx
        clear
        uprint
	;;
*)
	echo "error"
	exit
esac
