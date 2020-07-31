# vless_install
vless_install

方便自己使用的trojan和v2ray安装脚本（支持vless+ws+tls,vless+tcp+tls,vmess+ws+tls,vmess+tcp+tls）

debian10支持，ubuntu20.04支持，centos不支持，懒……，只是为了方便自己使用

安装:

apt install wget unzip -y

wget https://raw.githubusercontent.com/kakaruoterl/vless_install/master/vless.zip

unzip vless.zip && chmod +x vless_config.sh && ./vless_config.sh


补充说明:
如需更换科学上网方式请先执行7删除已安装的程序后再输入 ./vless_config.sh 进行选择安装
