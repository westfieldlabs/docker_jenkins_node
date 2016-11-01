FROM centos:7
MAINTAINER "Jeremy Shapiro" 

WORKDIR /opt/

RUN rpm -iUvh http://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-2.noarch.rpm
RUN yum update -y

# Install a basic SSH server GIT, UNZIP, LSOF and JDK 8
RUN yum install -y openssh-server \
	git \
	unzip \
	lsof \
	java-1.8.0-openjdk-headless \
	postgresql93 postgresql93-server postgresql93-contrib postgresql93-libs postgresql-devel\
	wget \
	which \
	sudo
RUN yum clean all
# update sshd settings, create jenkins user, set jenkins user pw, generate ssh keys
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
    && mkdir -p /var/run/sshd \
    && useradd -u 1000 -m -s /bin/bash jenkins \
    && echo "jenkins:jenkins" | chpasswd \
    && /usr/bin/ssh-keygen -A \
    && echo export JAVA_HOME="/`alternatives  --display java | grep best | cut -d "/" -f 2-6`" >> /etc/environment

#Add jenkins to sudoers
RUN echo 'jenkins ALL = (ALL) NOPASSWD:ALL' >> /etc/sudoers
#disable tty or sudo wont work 
RUN sed -i "s/requiretty/!requiretty/g" /etc/sudoers

#isntall RVM
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN sudo \curl -sSL https://get.rvm.io | bash -s stable --ruby

#install default rvm versions. 
RUN /usr/local/rvm/bin/rvm install 2.2.3
RUN /usr/local/rvm/bin/rvm install 2.2.2
RUN /usr/local/rvm/bin/rvm install 2.2.1
RUN /usr/local/rvm/bin/rvm install 2.3.0
RUN /usr/local/rvm/bin/rvm install 2.1.0

#install Heroku toolbelt
RUN sudo wget -qO- https://toolbelt.heroku.com/install.sh | sh 

#install apachae maven 3.2
RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
RUN sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
RUN yum -y install -y apache-maven-3.2.5-1.el6

#install redis 
RUN wget -r --no-parent -A 'epel-release-*.rpm' http://dl.fedoraproject.org/pub/epel/7/x86_64/e/
RUN rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-*.rpm
RUN yum install -y redis nodejs

#Create .ssh folder and add known hosts
RUN mkdir ~/.ssh
RUN mkdir /home/jenkins/.ssh/
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN ssh-keyscan github.com >> /home/jenkins/.ssh/known_hosts
RUN ssh-keyscan heroku.com >> ~/.ssh/known_hosts
RUN ssh-keyscan heroku.com >> /home/jenkins/.ssh/known_hosts

# chown to jenkins
RUN chown jenkins:jenkins  /home/jenkins/.ssh/known_hosts
RUN chown -R jenkins:jenkins /usr/local

# modify postgres
ADD utf8.sql utf8.sql
ADD modify_pg.sh modify_pg.sh
RUN chmod +x /opt/modify_pg.sh
RUN /opt/modify_pg.sh
RUN touch docker_runtime

#Copy entry script
COPY entry.sh /bin/entry.sh
RUN chmod +x /bin/entry.sh

RUN rm -rf /usr/bin/pg_dump
RUN ln -s /usr/pgsql-9.3/bin/pg_dump /usr/bin/pg_dump

EXPOSE 22

ENTRYPOINT ["entry.sh"]





