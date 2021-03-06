FROM amd64/centos:latest

# RUN yum install -y httpd
# ENV APACHE_RUN_USER  apache
# ENV APACHE_RUN_GROUP apache
# ENV APACHE_LOG_DIR  /var/log/httpd

RUN yum install -y net-tools telnet \
    sudo \
    epel-release

RUN yum install -y sshuttle \
    expect sshpass

ENV SSH_USERNAME     virl
ENV SSH_PASSWORD     VIRL
ENV SSH_HOST         10.81.59.228
ENV SSH_PORT         22
ENV SSH_OPTIONS      ''
# ENV SSHUTTLE_OPTIONS '-N --dns '
ENV SSHUTTLE_OPTIONS '-N --dns --disable-ipv6'

ENV SSHUTTLE_EXTRA_OPTIONS  ''

ENV SSHUTTLE_NETWORKS 172.16.1.0/24

RUN  useradd nsoadmin
RUN  usermod -aG wheel nsoadmin 
RUN echo "Defaults !authenticate" >> /etc/sudoers  

EXPOSE 8080

USER nsoadmin
WORKDIR /home/nsoadmin

RUN  mkdir .ssh
COPY --chown=nsoadmin:nsoadmin config/sshconfigfile .ssh/config

COPY --chown=nsoadmin:nsoadmin test-cmds/sh-run.sh sh-run.sh
COPY --chown=nsoadmin:nsoadmin test-cmds/httpserver_start.sh  httpserver_start.sh
COPY --chown=nsoadmin:nsoadmin test-cmds/runas_daemon.sh runas_daemon.sh

RUN  chmod +x sh-run.sh
RUN  chmod +x httpserver_start.sh
RUN  chmod +x runas_daemon.sh
# RUN  ssh-keygen -q -t rsa -N '' -f /home/nsoadmin/.ssh/id_rsa 2>/dev/null <<< y >/dev/null

RUN  chmod 600 /home/nsoadmin/.ssh/config
# CMD  ./runas_daemon.sh


COPY --chown=nsoadmin:nsoadmin entrypoint.sh entrypoint.sh
RUN  chmod 777      /home/nsoadmin/entrypoint.sh
ENTRYPOINT ["/bin/sh", "/home/nsoadmin/entrypoint.sh"]
