# vim:set ft=dockerfile:
FROM debian:buster

# Source Dockerfile:
# https://github.com/docker-library/postgres/blob/master/9.4/Dockerfile

# explicitly set user/group IDs
RUN groupadd -r freeswitch --gid=999 && useradd -r -g freeswitch --uid=999 freeswitch \
    && apt-get update && apt-get install -yq gnupg2 wget locales ca-certificates \
# grab gosu for easy step-down from root
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.11/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.11/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }').asc" \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
# make the "en_US.UTF-8" locale so freeswitch will be utf-8 enabled by default
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
# clean up to reduce image size (?)
    && rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove wget gnupg2 ca-certificates
ENV LANG en_US.utf8

ENV FS_MAJOR 1.10

RUN sed -i "s/buster main/buster main contrib non-free/" /etc/apt/sources.list

# Pull the git once and copy into container so that we do not need to keep pulling for every rebuild
COPY freeswitch /usr/src/freeswitch
WORKDIR /usr/src/freeswitch

# https://freeswitch.org/confluence/display/FREESWITCH/Debian+10+Buster
RUN apt-get update && apt-get install -yq wget gnupg2 git \
    && wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add - \
    && echo "deb http://files.freeswitch.org/repo/deb/debian-release/ buster main" > /etc/apt/sources.list.d/freeswitch.list \
    && echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ buster main" >> /etc/apt/sources.list.d/freeswitch.list \
    # > Install dependencies required for the build
    && apt-get update && apt-get build-dep freeswitch -y \    
# > ... and do the build
    && ./bootstrap.sh -j \
# add in mod_shout
    && sed -i "s+#formats/mod_shout+formats/mod_shout+g" modules.conf \
# make sure event socket is enabled
    && sed -i "s+#formats/mod_event_socket+formats/mod_event_socket+g" modules.conf \
    && ./configure \
    && make && make install \
# Clean up
    && rm -rf /var/lib/apt/lists/* \ 
    && apt-get purge -y --auto-remove gnupg2 wget git \
    # && apt-get purge -y --autoremove $(apt-cache showsrc freeswitch | sed -e '/Build-Depends/!d;s/Build-Depends: \|,\|([^)]*),*\|\[[^]]*\]//g') \
    && apt-get clean && apt-get autoremove

COPY docker-entrypoint.sh /
## Ports
# Open the container up to the world.
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 64535-65535/udp

WORKDIR /usr/src/freeswitch/conf
# Volumes
## Freeswitch Configuration
VOLUME ["/usr/local/freeswitch/conf"]
## Tmp so we can get core dumps out
VOLUME ["/tmp"]

# Limits Configuration
COPY    build/freeswitch.limits.conf /etc/security/limits.d/

# Healthcheck to make sure the service is running
SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  /usr/local/freeswitch/bin/fs_cli -x status | grep -q ^UP || exit 1

## Add additional things here

##

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["freeswitch"]
