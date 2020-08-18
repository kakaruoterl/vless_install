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

更新说明：

1、添加证书自动更新生成

2、添加证书手动更新：如果使用本脚本自动安装的证书，或者使用acme安装的ecc证书，才可以使用手动更新证书！

3、证书使用时间为90天，没必要频繁更新

4、如需升级脚本，请在删除原脚本后重新下载脚本！

初衷为自己使用，水平有限，时间有限，不能保证所有人的所有需求，深感抱歉！！！

最近没时间，vless的fallback暂时没时间去测试添加，所以如需要此功能的需自行配置，谢谢
