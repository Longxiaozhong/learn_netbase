FROM ubuntu:latest

LABEL maintainer "Long Xiao Zhong"

# Configure Repo
#RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak 
#RUN curl -o ./sjtug_mirror.repo -sSL "https://raw.githubusercontent.com/Longxiaozhong/learn_netbase/master/sjtug_mirror.repo"
#COPY  ./sjtug_mirror.repo  ./
#RUN mv ./sjtug_mirror.repo /etc/yum.repos.d/CentOS-Base.repo
#RUN cat /etc/yum.repos.d/CentOS-Base.repo
#RUN sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.conf
RUN rm -rf /etc/apt/sources.list && touch /etc/apt/sources.list 
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse"  >> /etc/apt/sources.list
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list

# update packages
#RUN yum clean all
#RUN yum makecache
#RUN yum repolist
#RUN yum -y update

# Install packages | Stop Firewall | Enable MariaDB and httpd
#RUN yum -y install mariadb-server mariadb php httpd php-mysql sudo; systemctl enable httpd; systemctl enable mariadb 
RUN apt search mysql
RUN apt-get -y update
RUN apt-get -y install ca-certificates
RUN apt-get -y install mariadb php httpd php-mysql
RUN /etc/init.d/httpd start
RUN /etc/init.d/mariadb start

# Change mysql cred
#RUN mysqladmin -u root password 'mysqlpassword'
#RUN mysql -uroot -pmysqlpassword -e "CREATE DATABASE rockxinhu"

# Software
RUN mkdir ./xinhu
COPY  ./xinhu  ./xinhu
RUN cd ./xinhu/ && \
	cp -R * /var/www/html/
	
#RUN cd /var/www/html/ && \
#	sed -i "s/'randkey'	=> ''/'randkey'=>'dswchjbmulkeoxizqafngprvty'/g"    ./webmain/webmainConfig.php1 && \
#	sed -i "s/'db_pass'	=> ''/'db_pass'	=> 'mysqlpassword'/g"    ./webmain/webmainConfig.php1  && \
#	mv ./webmain/webmainConfig.php1 ./webmain/webmainConfig.php 
	

# Import Tables to MariaDB
#RUN cd /var/www/html/ && \
#	mysql -u root -pmysqlpassword rockxinhu < ./webmain/install/rockxinhu.sql && \
#	rm -rf ./webmian/install

# Change permission
RUN chown apache /var/www/html/webmain/

EXPOSE 80 443 1688 3306 
CMD ["/usr/sbin/init"]
