#! /bin/bash
# echo_class自用，by kakaruoter

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"

if [ ! -d /opt/vless ];then
	mkdir /opt/vless
fi
if [ ! -d /root/432 ];then
	unzip html-p.zip
fi
mv /root/ws* /opt/vless &>/dev/null
mv /root/tcp.conf /opt/vless &>/dev/null
mv /root/tcp.json /opt/vless &>/dev/null
mv /root/tcpv.json /opt/vless &>/dev/null
mv /root/hap* /opt/vless &>/dev/null
mv /root/trojan.json /opt/vless/ &>/dev/null
mv /root/trojan.service /opt/vless/ &>/dev/null
mv /root/acupdate.sh /opt/vless/ &>/dev/null
chmod +x /opt/vless/acupdate.sh
mv /root/432 /opt/vless

v2ray_install() {
	if [ ! -d /usr/bin/v2ray ];then
		timedatectl set-timezone Asia/Shanghai 
		wget https://install.direct/go.sh
		chmod +x go.sh
		./go.sh &>/dev/null
	fi
	rm -rf /etc/v2ray/config.json
	uuid1=`cat /proc/sys/kernel/random/uuid` &>/dev/null
}

uuid1=`cat /proc/sys/kernel/random/uuid` &>/dev/null

vless_download() {
	mv /usr/bin/v2ray/* /opt
	cd /usr/bin/v2ray
	wget https://github.com/rprx/v2ray-vless/releases/download/clean2/v2ray-linux-64.zip
	unzip v2ray-linux-64.zip
	rm -rf v2ray-linux-64.zip
	chmod +x /usr/bin/v2ray/v2ray
	chmod +x /usr/bin/v2ray/v2ctl
	cd
}

checkIP() {
 # read -p "请输入你所绑定到本vps的域名: " dname
  #local realIP="$(curl -s `curl -s https://raw.githubusercontent.com/phlinhng/v2ray-tcp-tls-web/master/custom/ip_api`)"
  	local realIP="$(curl -s ifconfig.me)"
  	local resolvedIP="$(ping $dname -c 1 | head -n 1 | grep  -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"

  	if [[ "${realIP}" == "${resolvedIP}" ]]; then
    	return 0
  	else
    	return 1
  	fi
}

install_all() {
	while true; do
	read -p "请输入您绑定到本vps的域名:" dname
	echo -e "${Green_font_prefix}域名解析中...${Font_color_suffix}"
	checkIP
	if checkIP "${dname}"; then
		echo -e "${Green_font_prefix}解析正确, 即将开始安装${Font_color_suffix}"
		break
	else
		echo -e "${Red_font_prefix}解析错误，请重新输入!${Font_color_suffix}"
		continue
	fi
	done
	sed -i 's/example.com/'$dname'/g' /opt/vless/acupdate.sh
}


trojan_install() {
	read -p "请输入trojan密码:" password1
	mkdir /etc/v2ray
	cd /etc/
	wget https://github.com/trojan-gfw/trojan/releases/download/v1.16.0/trojan-1.16.0-linux-amd64.tar.xz
	tar -xf trojan-1.16.0-linux-amd64.tar.xz
	rm -rf trojan-1.16.0-linux-amd64.tar.xz
	cp /etc/trojan/trojan /usr/bin/
	cp /etc/trojan/trojan /etc/init.d
	rm -rf /etc/trojan/config.json
	cd
	cp /opt/vless/trojan.service /etc/systemd/system/trojan.service
#	sed -i 's/passwd/'$password1'/g' /opt/vless/trojan.json
	cp /opt/vless/trojan.json /etc/trojan/
}

change_json() {
	sed -ri '10s/.*/            "id":"'$uuid1'"/' /opt/vless/ws.json
	sed -ri '10s/.*/                        "id":"'$uuid1'"/' /opt/vless/tcp.json
	sed -ri '10s/.*/              "id":"'$uuid1'",/' /opt/vless/wsv.json
	sed -ri '10s/.*/                        "id":"'$uuid1'",/' /opt/vless/tcpv.json 
	sed -i 's/example.com/'$dname'/g' /opt/vless/tcp.conf
	sed -i 's/example.com/'$dname'/g' /opt/vless/ws.conf
}

acme_install() {
	if [ ! -f /root/.acme.sh/${dname}_ecc/fullchain.cer ];then
		apt-get install openssl cron socat curl -y	
		curl  https://get.acme.sh | sh
		~/.acme.sh/acme.sh --issue -d $dname --standalone --keylength ec-256 --force
		~/.acme.sh/acme.sh --installcert -d $dname --ecc \
                          	--fullchain-file /etc/v2ray/v2ray.crt \
                          	--key-file /etc/v2ray/v2ray.key
		
	else
		if [ ! -f /etc/v2ray/v2ray.crt ];then
			rm -rf /etc/v2ray/*.crt
			rm -rf /etc/v2ray/*.key
			cd /root/.acme.sh/${dname}_ecc
			cp fullchain.cer /etc/v2ray/v2ray.crt
			cp $dname.key /etc/v2ray/v2ray.key
		fi
	fi

	if [ -d /var/www/.caddy/acme ];then
		rm -rf /etc/v2ray/v2ray.crt
		rm -rf /etc/v2ray/v2ray.key
		cd /var/www/.caddy/acme/acme-v02.api.letsencrypt.org/sites/$dname
		cp $dname.crt /etc/v2ray/v2ray.crt
		cp $dname.key /etc/v2ray/v2ray.key
		cd
	fi
	mkdir /etc/ssl/private
	cat /etc/v2ray/v2ray.crt /etc/v2ray/v2ray.key > /etc/ssl/private/v2ray.pem
	echo "59 1 31 * * bash /opt/vless/update.sh" >> /var/spool/cron/crontabs/root
}
#vless_ws() {
#	cp ws.json /etc/v2ray/config.json
#}

acme_upgrade() {
	~/.acme.sh/acme.sh --renew -d $dname --force --ecc
	~/.acme.sh/acme.sh --installcert -d $dname --ecc --fullchain-file /etc/v2ray/v2ray.crt --key-file /etc/v2ray/v2ray.key
	cat /etc/v2ray/v2ray.crt /etc/v2ray/v2ray.key > /etc/ssl/private/v2ray.pem
}

haproxy_install() {
	if [ ! -f /etc/haproxy/haproxy.cfg ];then
		apt install haproxy -y
	fi
	rm -rf /etc/haproxy/haproxy.cfg
	
	cp /opt/vless/haproxy.cfg /etc/haproxy/haproxy.cfg
}

bbr_install() {
	wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"
	chmod +x tcp.sh
	./tcp.sh
}

delete() {
#	rm -rf /opt/vless*
	rm -rf /root/html-p.zip
	rm -rf /root/432
	rm -rf /root/vless.zip
#	rm -rf /root/432
}

html_install() {
	rm -rf /var/www/html/*
	cp -r /opt/vless/432/* /var/www/html/
}

uprint() {
	echo ""
	echo -e "${Green_font_prefix}你的uuid为：$uuid1${Font_color_suffix}"
}

pathprint() {
	echo -e "${Green_font_prefix}ws路径:/ray${Font_color_suffix}"
	echo -e "${Green_font_prefix}alterId:0${Font_color_suffix}"
}

nginx_install() {
		if [ ! -d /etc/nginx ];then
				apt install nginx -y
		fi
		rm -rf /etc/nginx/conf.d/*
		systemctl stop caddy
		systemctl disable caddy
		systemctl stop httpd
		systemctl disable httpd
}

delete_all() {
	read -p "将会删除证书文件以外的其它科学上网程序，请确定(y/n):" yn
	case "$yn" in
	[yY])
		apt remove haproxy -y &>/dev/null
		systemctl stop trojan &>/dev/null
		systemctl stop haproxy &>/dev/null
		rm -rf /etc/v2ray/config.json &>/dev/null
		rm -rf /etc/trojan &>/dev/null
		rm -rf /usr/bin/v2ray &>/dev/null
		rm -rf /usr/bin/trojan &>/dev/null
		rm -rf /etc/init.d/v2ray &>/dev/null
		rm -rf /etc/init.d/trojan &>/dev/null
		rm -rf /etc/systemd/system/trojan.service &>/dev/null
		rm -rf /etc/systemd/system/v2ray.service &>/dev/null
		rm -rf /etc/systemd/system/haproxy.service &>/dev/null
		rm -rf /etc/haproxy/haproxy.cfg &>/dev/null
		rm -rf /etc/nginx/conf.d/*
		rm -rf /root/go*
		rm -rf /opt/v2ray
		rm -rf /opt/v2ctl
		rm -rf /opt/geo*
		;;
	[nN])
		exit
		;;
	*)
		echo -e "${Red_font_prefix}error${Font_color_suffix}"
		exit
	esac
}

clear

echo && echo -e "          科学上网一键安装脚本：       
         ${Green_font_prefix}----  by echo_class ----${Font_color_suffix}
      ——————————————————————————————————
             ${Green_font_prefix}1、${Font_color_suffix}vless+ws+tls+web
             ${Green_font_prefix}2、${Font_color_suffix}vless+tcp+tls+web
             ${Green_font_prefix}3、${Font_color_suffix}vmess+ws+tls+web
             ${Green_font_prefix}4、${Font_color_suffix}vmess+tcp+tls+web
             ${Green_font_prefix}5、${Font_color_suffix}trojan
             ${Green_font_prefix}6、${Font_color_suffix}bbr install(bbr安装完成且重启vps后请执行 ./tcp.sh 以启动bbr服务)
             ${Green_font_prefix}7、${Font_color_suffix}delete all
             ${Green_font_prefix}8、${Font_color_suffix}手动更新证书(仅支持使用此脚本安装的证书)
             ${Green_font_prefix}9、${Font_color_suffix}exit
      ——————————————————————————————————
         ${Green_font_prefix}该脚本会自动安装伪装网站${Font_color_suffix}"
#read -p "请输入您绑定的域名(务必输入正确！)": dname
#install_all
echo
read -p "请输入您的选择:" choice
case "$choice" in
1)
	install_all
	v2ray_install
#	vless_download
#	change_json
	acme_install
	nginx_install
	cp /opt/vless/wsv.json /etc/v2ray/config.json
	cp /opt/vless/ws.conf /etc/nginx/conf.d/ws.conf
	sed -ri '10s/.*/              "id":"'$uuid1'",/' /etc/v2ray/config.json
	sed -i 's/example.com/'$dname'/g' /etc/nginx/conf.d/ws.conf
	html_install
	systemctl daemon-reload
	systemctl restart v2ray
	systemctl restart nginx
	delete
	clear
	uprint
	pathprint
	;;
2)
	install_all
	v2ray_install
#	vless_download
#	change_json
	acme_install
	nginx_install
	haproxy_install
	cp /opt/vless/tcpv.json /etc/v2ray/config.json
	cp /opt/vless/tcp.conf /etc/nginx/conf.d/tcp.conf
	sed -i 's/example.com/v2ray/g' /etc/haproxy/haproxy.cfg
	sed -ri '10s/.*/                        "id":"'$uuid1'",/' /etc/v2ray/config.json
	sed -i 's/example.com/'$dname'/g' /etc/nginx/conf.d/tcp.conf
	html_install
	systemctl daemon-reload
	systemctl restart v2ray
	systemctl restart nginx
	systemctl restart haproxy
	delete
	clear
	uprint
	echo -e "${Green_font_prefix}alterId:0${Font_color_suffix}"
	;;
3)
	install_all
	v2ray_install
#	change_json
	acme_install
	nginx_install
	cp /opt/vless/ws.json /etc/v2ray/config.json
	cp /opt/vless/ws.conf /etc/nginx/conf.d/ws.conf
	sed -ri '10s/.*/            "id":"'$uuid1'"/' /etc/v2ray/config.json
	sed -i 's/example.com/'$dname'/g' /etc/nginx/conf.d/ws.conf
	html_install
	systemctl daemon-reload
	systemctl restart v2ray
	systemctl restart nginx
	clear
	delete
	uprint
	pathprint
	;;
4)
	install_all
	v2ray_install
#	change_json
	acme_install
	nginx_install
	haproxy_install
	cp /opt/vless/tcp.json /etc/v2ray/config.json
	cp /opt/vless/tcp.conf /etc/nginx/conf.d/tcp.conf
	sed -i 's/example.com/v2ray/g' /etc/haproxy/haproxy.cfg
	sed -ri '10s/.*/                        "id":"'$uuid1'"/' /etc/v2ray/config.json
	sed -i 's/example.com/'$dname'/g' /etc/nginx/conf.d/tcp.conf
	html_install
	systemctl daemon-reload
	systemctl restart v2ray
	systemctl restart nginx
	systemctl restart haproxy
	delete
	clear
	uprint
	echo -e "${Green_font_prefix}alterId:0${Font_color_suffix}"
	;;
5)
	install_all
	trojan_install
#	change_json
	acme_install
	nginx_install
	cp /opt/vless/tcp.conf /etc/nginx/conf.d/tcp.conf
	sed -i 's/example.com/'$dname'/g' /etc/nginx/conf.d/tcp.conf
	sed -i 's/passwd/'$password1'/g' /etc/trojan/trojan.json
	html_install
	systemctl restart nginx
	systemctl daemon-reload
	systemctl restart trojan
	delete
	clear
	echo -e "${Greed_font_prefix}trojan部署完成！${Font_color_suffix}"
	;;
6)
	bbr_install
	;;
7)
	delete_all
	;;
8)
    systemctl stop nginx
    systemctl stop haproxy
    install_all
    acme_upgrade
    systemctl start nginx
    systemctl start haproxy
	;;	
9)
	exit
	;;
*)
	echo -e "${Red_background_prefix}error${Font_color_suffix}"
	exit
esac
