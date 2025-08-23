FROM ubuntu:latest

RUN useradd -rm -d /home/fish -s /bin/bash -u 999 fish

RUN passwd --delete fish

USER fish

WORKDIR /home/fish

COPY fishies ./

USER root

RUN echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update \
  && apt-get install -y bash openssh-server vim make libcurses-perl \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

RUN echo "Match User fish\n X11Forwarding no\n AllowTcpForwarding no\n ForceCommand /home/fish/fishies" >> /etc/ssh/sshd_config

RUN mkdir /var/run/sshd

RUN cpan -I Term::Animation

CMD ["/usr/sbin/sshd", "-D"]
