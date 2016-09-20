FROM vibioh/ftp

MAINTAINER Lauser, Nicolai <nicolai@lauser.info>

ADD docker-entrypoint.sh /

RUN chmod 775 /docker-entrypoint.sh \
    && mkdir -p /ftp \
    && mkdir -p /templates

VOLUME /templates
WORKDIR /ftp

ENTRYPOINT ["/docker-entrypoint.sh"]