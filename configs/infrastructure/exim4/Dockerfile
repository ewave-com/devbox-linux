FROM ubuntu:16.04

MAINTAINER Anatoliy Zbirovskiy <anatoliy.zbirovskiy@ewave.com>

ENV LC_ALL C.UTF-8
ENV TINI_VERSION v0.9.0

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y exim4-daemon-light libperl4-corelibs-perl && \
     rm -rf /var/lib/apt/lists/*

# Add Tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# Run your program under Tini
ADD ./config/exim4/* /etc/exim4/
RUN ["chown", "Debian-exim", "/etc/exim4/mail.website.com.key"]
RUN ["update-exim4.conf"]

CMD ["exim", "-bd", "-q1m"]
