# This is a comment
FROM ubuntu:latest
MAINTAINER Arsenii Gorkin <gorkin@protonmail.com>

#Updating/upgrading system and dists
RUN apt-get -y update && apt-get -qy -y upgrade && apt-get -qy -y dist-upgrade

#Setting ENVs
ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LC_ALL=C.UTF-8 LANGUAGE=en_US.UTF-8
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR=/var/run/apache2

#Installing essentials and Perl
RUN apt-get install -y apt-utils
RUN apt-get install -y build-essential
RUN apt-get install -qy -y cpanminus
RUN apt-get install -qy -y perl
RUN apt-get install -y nano

#Installing Perl modules
RUN ["cpanm", "Term::ReadLine", "ExtUtils::Installed"]

#Installing Apache
RUN apt-get update && apt-get install -y apache2

#Preparing the server
#CMD ["service", "apache2", "restart", "FOREGROUND"]

#Installing mod_perl
RUN apt-get install -y libapache2-mod-perl2
RUN a2enmod perl

#Configuring Apache2
RUN a2enmod cgi
RUN a2enmod rewrite
RUN ["rm", "/etc/apache2/apache2.conf"]
ADD ./apache/apache2.conf /etc/apache2/apache2.conf
RUN ["rm", "/etc/apache2/conf-enabled/serve-cgi-bin.conf"]
ADD ./apache/serve-cgi-bin.conf /etc/apache2/conf-enabled/serve-cgi-bin.conf
RUN ["mkdir", "/var/www/cgi-bin"]
RUN ["rm", "/etc/apache2/sites-enabled/000-default.conf"]
ADD ./apache/000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD ./apache/servername.conf /etc/apache2/conf-available/servername.conf
RUN ["a2enconf", "servername"]
RUN service apache2 restart FOREGROUND

#Starter needs to start the server at the startup and keep a container working as long as we need
COPY ./apache/starter /starter
RUN ["chmod", "0755", "/starter"]

#Cleaning
RUN apt-get clean

#Deploying the software
COPY ./app/test.pl /var/www/cgi-bin
RUN ["chmod", "0755", "/var/www/cgi-bin/test.pl"]

#Starting Apache2
EXPOSE 80
ENTRYPOINT ["sh", "/starter"]

