FROM ubuntu:16.04
LABEL maintainer="wisfern@gmail.com"

RUN sed -i 's#http://archive.ubuntu.com/#http://mirrors.aliyun.com/#;s#http://security.ubuntu.com/#http://mirrors.aliyun.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated --fix-missing \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        curl net-tools \
        lxde x11vnc xvfb xrdp \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        firefox nginx \
        python-pip python-dev build-essential \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta \
        dbus-x11 x11-utils \
        zsh \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*


# tini for subreap                                   
ARG TINI_VERSION=v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini \
    && useradd -m -d /home/guest -p guest guest --groups adm,sudo \
    && echo 'guest:docker' | chpasswd \
    && chsh -s /bin/zsh guest 

ADD image/usr/lib/web/requirements.txt /tmp/
RUN pip install setuptools wheel && pip install -r /tmp/requirements.txt
ADD image /

EXPOSE 80
EXPOSE 3389

WORKDIR /root
ENV HOME=/home/guest \
    SHELL=/bin/bash

#RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
#RUN echo "ubuntu:PASSWD" | chpasswd
    
ENTRYPOINT ["/startup.sh"]
