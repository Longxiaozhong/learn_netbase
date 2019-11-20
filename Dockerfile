FROM centos:7

LABEL maintainer "Long Xiao Zhong"

USER root
WORKDIR /

RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs

# Configure Repo
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak 
#RUN curl -o ./sjtug_mirror.repo -sSL "https://raw.githubusercontent.com/Longxiaozhong/learn_netbase/master/sjtug_mirror.repo"
COPY  ./sjtug_mirror.repo  ./
RUN mv ./sjtug_mirror.repo /etc/yum.repos.d/CentOS-Base.repo
RUN cat /etc/yum.repos.d/CentOS-Base.repo
RUN sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.conf

# Stop Firewall
# RUN systemctl disable firewalld --now

# Disable SELinux
#RUN setenforce 0

# update packages
RUN yum clean all
RUN yum makecache
RUN yum repolist
RUN yum -y update

# Enable Systemd
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install packages
RUN yum -y install mariadb-server mariadb php httpd 
# Enable MariaDB
RUN sudo systemctl start httpd 
RUN sudo systemctl start mariadb 


# Change mysql cred
RUN mysqladmin -u root password 'mysqlpassword'
RUN mysql -uroot -pmysqlpassword -e "CREATE DATABASE rockxinhu"


# Download Software
RUN yum -y install git
#RUN git clone "https://github.com/rainrocka/xinhu.git"
RUN mkdir ./xinhu
COPY  ./xinhu  ./xinhu
RUN cd ./xinhu/ && \
	cp -R * /var/www/html/ && \
	cd /var/www/html/ && \
	sed -i "s/'randkey'	=> ''/'randkey'=>'dswchjbmulkeoxizqafngprvty'/g"    ./webmain/webmainConfig.php1 && \
	sed -i "s/'db_pass'	=> ''/'db_pass'	=> 'mysqlpassword'/g"    ./webmain/webmainConfig.php1  && \
	mv ./webmain/webmainConfig.php1 ./webmain/webmainConfig.php 
	

# Import Tables to MariaDB
RUN cd /var/www/html/ && \
	mysql -u root -pmysqlpassword rockxinhu < ./webmain/install/rockxinhu.sql && \
	rm -rf ./webmian/install
	
# Restart Services
RUN sudo systemctl restart httpd

# Change permission
RUN sudo chown apache /var/www/html/webmain/

EXPOSE 80 443 3306


