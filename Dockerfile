FROM centos:7

LABEL maintainer "Long Xiao Zhong"

USER root
WORKDIR /


ENV container docker

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

# Use Systemctl
RUN curl -o ./systemctl.py -sSL https://raw.githubusercontent.com/gdraheim/docker-systemctl-images/master/files/docker/systemctl.py
RUN mv ./systemctl.py    /usr/bin/systemctl


# Configure Repo
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak 
#RUN curl -o ./sjtug_mirror.repo -sSL "https://raw.githubusercontent.com/Longxiaozhong/learn_netbase/master/sjtug_mirror.repo"
COPY  ./sjtug_mirror.repo  ./
RUN mv ./sjtug_mirror.repo /etc/yum.repos.d/CentOS-Base.repo
RUN cat /etc/yum.repos.d/CentOS-Base.repo
RUN sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.conf

#Install systemd:
#RUN yum -y install systemd; yum clean all;

# Stop Firewall
#RUN systemctl disable firewalld --now

# Disable SELinux
#RUN setenforce 0

# update packages
RUN yum clean all
RUN yum makecache
RUN yum repolist
RUN yum -y update



# Install packages
RUN yum -y install mariadb-server mariadb php httpd sudo 
# Enable MariaDB and httpd
#RUN systemctl start httpd 
RUN /etc/init.d/httpd start
RUN /etc/init.d/mariadb start
#RUN systemctl start mariadb 


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
#RUN systemctl restart httpd
RUN /etc/init.d/httpd restart


# Change permission
RUN chown apache /var/www/html/webmain/

EXPOSE 80 443 1688 3306 


