#! /bin/bash
# echo_class自用，by kakaruoter

mkdir /root/vless
mv /root/ws* /root/vless
mv /root/tcp* /root/vless
mv /root/hap* /root/vless
mv /root/trojan.json /root/vless/
mv /root/trojan.service /root/vless/

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
	chmod +x /usr/bin/v2ray/v2ray
	chmod +x /usr/bin/v2ray/v2ctl
	cd /root/
}

trojan_install() {
	mkdir /etc/v2ray
	cd /etc/
	wget https://github.com/trojan-gfw/trojan/releases/download/v1.16.0/trojan-1.16.0-linux-amd64.tar.xz
	tar -xf trojan-1.16.0-linux-amd64.tar.xz
	rm -rf trojan-1.16.0-linux-amd64.tar.xz
	cp /etc/trojan/trojan /usr/bin/
	cp /etc/trojan/trojan /etc/init.d
	rm -rf /etc/trojan/config.json
	cd
	mv /root/vless/trojan.service /etc/systemd/system/trojan.service
	read -p "请输入trojan密码:" password1
	sed -i 's/passwd/'$password1'/g' /root/vless/trojan.json
	cp /root/vless/trojan.json /etc/trojan/
}

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

delete() {
	rm -rf /root/vless
	rm -rf /root/vless.zip
	rm -rf /root/html-p.zip
	rm -rf /root/432
}

html_install() {
	unzip html-p.zip
	rm -rf /var/www/html/*
	cp -r /root/432/* /var/www/html/
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
            ############################
            #        请选择             #
            # 1、vless+ws+tls+web      #
            # 2、vless+tcp+tls+web     #
            # 3、vmess+ws+tls+web      #
            # 4、vmess+tcp+tls+web     #
            # 5、trojan                #
            ############################
EOF

read -p "请输入您绑定的域名(务必输入正确！)": dname
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
	html_install
	systemctl restart v2ray
	systemctl restart nginx
	delete
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
	html_install
	systemctl restart v2ray
	systemctl restart nginx
	systemctl restart haproxy
	delete
	clear
	uprint
	;;
3)
	v2ray_install
	change_json
	acme_install
	apt install nginx -y
	cp /root/vless/ws.json /etc/v2ray/config.json
	cp /root/vless/ws.conf /etc/nginx/conf.d/ws.conf
	html_install
	systemctl restart v2ray
	systemctl restart nginx
	clear
    delete
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
	html_install
    systemctl restart v2ray
    systemctl restart nginx
	systemctl restart haproxy
    delete
	clear
    uprint
	;;
5)
	trojan_install
	acme_install
	apt install nginx -y
	cp /root/vless/tcp.conf /etc/nginx/conf.d/tcp.conf
	html_install
	systemctl restart nginx
	systemctl restart trojan
	delete
	clear
	echo "trojan部署完成！"
	;;
*)
	echo "error"
	exit
esac
