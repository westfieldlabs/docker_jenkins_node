FROM centos:7
MAINTAINER "Mitch Eaton" 

WORKDIR /opt/

RUN yum update -y
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/2.52/remoting-2.52.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# Install a basic SSH server GIT, UNZIP, LSOF and JDK 8
RUN yum install -y openssh-server git unzip lsof java-1.8.0-openjdk-headless && yum clean all
# update sshd settings, create jenkins user, set jenkins user pw, generate ssh keys
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd \
    && mkdir -p /var/run/sshd \
    && useradd -u 1000 -m -s /bin/bash jenkins \
    && echo "jenkins:jenkins" | chpasswd \
    && /usr/bin/ssh-keygen -A \
    && echo export JAVA_HOME="/`alternatives  --display java | grep best | cut -d "/" -f 2-6`" >> /etc/environment

#Copy Jenkins exec for JNLP
COPY jenkins-slave /bin/jenkins-slave
RUN chmod +x /bin/jenkins-slave

#Create .ssh folder and add known hosts
RUN mkdir ~/.ssh
RUN mkdir /home/jenkins/.ssh/
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN ssh-keyscan github.com >> /home/jenkins/.ssh/known_hosts
RUN ssh-keyscan heroku.com >> ~/.ssh/known_hosts
RUN ssh-keyscan heroku.com >> /home/jenkins/.ssh/known_hosts

#install wget
RUN yum install -y wget 

#Install which 
RUN yum install -y which 

#install sudo
RUN yum install -y sudo 

#Add jenkins to sudoers
RUN echo 'jenkins ALL=(ALL:ALL) ALL' >> /etc/sudoers
#disable tty or sudo wont work 
RUN sed -i "s/requiretty/!requiretty/g" /etc/sudoers

#isntall RVM
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN sudo \curl -sSL https://get.rvm.io | bash -s stable --ruby

#install Heroku toolbelt
RUN sudo wget -qO- https://toolbelt.heroku.com/install.sh | sh 

#install apachae maven 3.2
RUN wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
RUN sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
RUN yum -y install -y apache-maven-3.2.5-1.el6

EXPOSE 22
ENTRYPOINT ["jenkins-slave"]