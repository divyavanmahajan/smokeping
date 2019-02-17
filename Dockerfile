FROM linuxserver/smokeping:latest

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SMOKEPING_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL build_version="Extension to update Smokeping"
LABEL maintainer="Divya Mahajan"

# copy tcpping script
COPY tcpping /usr/bin/tcpping

# add local files
COPY root/ /

# Update Smokeping
RUN \
    curl -L -o /tmp/smokeping.zip https://github.com/oetiker/SmokePing/archive/master.zip \
&&  cd /tmp \
&&  unzip -o smokeping.zip \
&&  cp -Rv /tmp/SmokePing-master/htdocs/css /usr/share/webapps/smokeping/ \
&&  cp -Rv /tmp/SmokePing-master/htdocs/js /usr/share/webapps/smokeping/ \
&&  rm -rf /usr/share/webapps/smokeping/cropper \
&&  cp /tmp/SmokePing-master/etc/basepage.html.dist /etc/smokeping/basepage.html \
&&  cp /tmp/SmokePing-master/bin/smokeping /usr/bin \
&&  cp /tmp/SmokePing-master/bin/smokeping_cgi /usr/bin \
&&  cp /tmp/SmokePing-master/bin/smokeinfo /usr/bin \
&&  cp /tmp/SmokePing-master/lib/*.pm /usr/share/perl5/vendor_perl/ \
&&  cp -Rv /tmp/SmokePing-master/lib/Smokeping/* /usr/share/perl5/vendor_perl/Smokeping \
&&  chmod ug+s /usr/bin/tcpping \
&&  chmod +rx /usr/bin/tcpping

# ports and volumes
EXPOSE 80
VOLUME /config /data /cache
