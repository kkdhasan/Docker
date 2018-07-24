
###################################################################################################################
#   Author                      : Kanna Kathalingam                                                               #
#   Version                     : 1.0                                                                             #
#   Release Date                : 30 Aug 2017                                                                     #
#   Description                 : This script will build docker Application images                                #
#   Release notes               : Apache 2.4, PHP 5.6 		Autobuild test 				                  #
###################################################################################################################

# Set the base image to Ubuntu
FROM ubuntu:16.04

# File Author / Maintainer
MAINTAINER Kanna Kathalingam <kkdhasan@gmail.com>

#User Creation  #Add our user and group
RUN groupadd -r webuser && useradd -r --create-home -g webuser webuser

#Create directory 
RUN mkdir -p "/var/www/log" 

# Setting up the Enviroment Variables
ENV APACHE_RUN_USER webuser
ENV APACHE_RUN_GROUP webuser
ENV APACHE_LOG_DIR /var/www/log
#ENV APACHE_PID_FILE /opt/www/apps/logs 
ENV APACHE_HOME /etc/apache2

# Update the repository
RUN apt-get update -y \
	&& apt-get install -y python-software-properties software-properties-common \
	&& apt-get install -y  vim curl wget \ 
	&& LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
	&& apt-get update 

# Apache installation 
RUN apt-get install -y apache2 \
    && apt-get install -y php5.6 libapache2-mod-php5.6 php5.6-bz2 \
	php5.6-cli php5.6-common php5.6-curl php5.6-dba php5.6-gd php5.6-gmp \
	php5.6-imap php5.6-intl php5.6-ldap php5.6-mbstring php5.6-mcrypt php5.6-mysql \
	php5.6-odbc php5.6-pgsql php5.6-recode php5.6-snmp php5.6-soap \
	php5.6-sqlite php5.6-tidy php5.6-xml php5.6-xmlrpc php5.6-xsl php5.6-zip
 
#Apache & PHP Configuration modify 
RUN \ 
        sed -i -e 's/max_execution_time = 30/max_execution_time = 300/g' /etc/php/5.6/apache2/php.ini \
	&& sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/5.6/apache2/php.ini \
        && sed -i -e 's/post_max_size = 8M/post_max_size = 512M/g' /etc/php/5.6/apache2/php.ini \
	&& sed -i -e 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/5.6/apache2/php.ini \
	&& sed -i -e 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml  index.htm/g' /etc/apache2/mods-available/dir.conf \
	&& sed  -i '/#ServerName www.example.com/c\ ServerName localhost' /etc/apache2/sites-available/000-default.conf \ 	
	&& sed  -i '/ServerAdmin/c\	ServerAdmin oracletechnologysmj2ee@nbcuni.com' /etc/apache2/sites-available/000-default.conf \
        && sed -i '/APACHE_LOG_DIR/c\	export APACHE_LOG_DIR=/var/www/log/' /etc/apache2/envvars \
        && sed -i '/APACHE_RUN_USER/c\  export APACHE_RUN_USER=webuser' /etc/apache2/envvars \
        && sed -i '/APACHE_RUN_GROUP/c\ export APACHE_RUN_GROUP=webuser' /etc/apache2/envvars
 
   #  && sed -i '/DocumentRoot/c\     DocumentRoot /opt/www/apps/web-content/' /etc/apache2/sites-available/000-default.conf \
   # && sed -i '/ErrorLog/c\ ErrorLog  "|/usr/bin/rotatelogs /opt/www/apps/logs/error_log-%Y-%m-%d-%H 86400"' /etc/apache2/sites-available/000-default.conf \
   # && sed -i '/CustomLog/c\ CustomLog "|/usr/bin/rotatelogs /opt/www/apps/logs/access_log-%Y-%m-%d-%H 86400" combined' /etc/apache2/sites-available/000-default.conf \

#Clean-UP 
RUN apt-get remove -y \
	python-software-properties \
	software-properties-common \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* 
	
# Set the Volume
VOLUME /var/www/ 

# Set the port
EXPOSE 80
	
# Set the entry point for the apache
ENTRYPOINT ["/usr/sbin/apachectl"]
CMD ["-D", "FOREGROUND"] 
