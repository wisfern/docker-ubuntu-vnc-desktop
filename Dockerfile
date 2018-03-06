FROM ubuntu:16.04
LABEL maintainer="wisfern@gmail.com"

RUN sed -i 's#http://archive.ubuntu.com/#http://mirrors.163.com/ubuntu/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl \
    && sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        openssh-server pwgen sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb xrdp \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        fonts-wqy-microhei \
        language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
        dbus-x11 x11-utils \
        zsh \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*


# tini for subreap                                   
ARG TINI_VERSION=v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini \
    && useradd -m -d /home/guest -p guest guest --groups adm,sudo \
    && echo 'guest:docker' | chpasswd \
    && chsh -s /bin/zsh guest \
    && echo "cleanup xrdp" \
    && /etc/init.d/xrdp force-stop

ADD image/usr/lib/web/requirements.txt /tmp/
RUN pip install setuptools wheel && pip install -r /tmp/requirements.txt
ADD image /

EXPOSE 80
WORKDIR /root
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash

#RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo ubuntu
#RUN echo "ubuntu:PASSWD" | chpasswd
    
ENTRYPOINT ["/startup.sh"]
