## 一、简介

1. 该一键安装包是一个`Shell`脚本，用于一键安装`PureFTPd`及`web`管理界面。
2. 适用于`Debian/Ubuntu/Red Hat/CentOS`系统。
3. 支持`MySQL`用户，可设置相关权限及密码。
4. 安装方便，卸载干净，绿色无污染。
5. 脚本简单，可自行修改编译参数，这不容易造成安装错误。

## 二、安装步骤

	yum -y install git
	apt-get -y install git
	git clone git://github.com/wangyan/pureftpd.git
	cd pureftpd
	./install.sh

1. 输入服务器IP地址
2. 网站根目录
3. `MySQL Root` 用户密码
4. `MySQL ftpuser` 用户密码，该用户是专门用来管理`PureFTPd`的。（该密码不需要你记住）
5. `Administartor` 用户密码，该密码是Web管理界面管理员帐号密码。
6. 按任意键开始安装
7. 访问`http://服务器IP地址/ftp`进行管理

被动模式端口是`30000-50000`，加载了防火墙的服务器需要开放该端口。
更多配置选项，请修改`/usr/local/pureftpd/conf/pureftpd.conf`文件。

图文安装教程：[http://wangyan.org/blog/pureftpd-install-script.html](http://wangyan.org/blog/pureftpd-install-script.html)

## 三、联系方式

> Email: [WangYan@188.com](WangYan@188.com) （推荐）    
> Gtalk: [myidwy@gmail.com](myidwy@gmail.com)    
> Twitter：[@wang_yan](https://twitter.com/wang_yan)    
> Home Page: [WangYan Blog](http://wangyan.org/blog)    