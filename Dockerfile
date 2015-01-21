FROM ubuntu
MAINTAINER Antonio Verni <me.verni@gmail.com>

ENV VCL_CONFIG      /etc/varnish/default.vcl
ENV CACHE_SIZE      64m
ENV VARNISHD_PARAMS -p default_ttl=3600 -p default_grace=3600
ENV MUNIN_SERVER .*

RUN apt-get update -y && apt-get install -y curl apt-transport-https git build-essential autoconf automake1.1 autotools-dev groff-base make libedit-dev libncurses-dev libpcre3-dev libtool pkg-config python-docutils libmhash-dev
RUN curl https://repo.varnish-cache.org/ubuntu/GPG-key.txt | apt-key add -
RUN echo "deb https://repo.varnish-cache.org/ubuntu/ trusty varnish-4.0" >> /etc/apt/sources.list.d/varnish-cache.list
RUN apt-get update -y && apt-get install -y varnish libvarnishapi-dev

RUN cd /tmp && \
  git clone https://github.com/varnish/libvmod-vsthrottle.git && \
  cd libvmod-vsthrottle && \
  git checkout master && \
  ./autogen.sh && \
  ./configure VARNISHSRC=/usr/include/varnish && \
  make && \
  make install

RUN cd /tmp && \
  git clone https://github.com/varnish/libvmod-digest.git && \
  cd libvmod-digest && \
  git checkout master && \
  ./autogen.sh && \
  ./configure VARNISHSRC=/usr/include/varnish && \
  make && \
  make install

RUN cd /tmp && \
  git clone https://github.com/varnish/libvmod-header.git && \
  cd libvmod-header && \
  git checkout master && \
  ./autogen.sh && \
  ./configure VARNISHSRC=/usr/include/varnish && \
  make && \
  make install

RUN apt-get install -y munin-node libxml-parser-perl
RUN (sed -i "s/^allow [\^]127.*\$/allow \^${MUNIN_SERVER}\$/g" /etc/munin/munin-node.conf)
ADD varnish-plugin.d.conf /etc/munin/plugin-conf.d/varnish
RUN curl https://raw.githubusercontent.com/munin-monitoring/contrib/master/plugins/varnish4/varnish4_ > /usr/share/munin/plugins/varnish4_ 
RUN chmod +x /usr/share/munin/plugins/varnish4_
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_request_rate
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_hit_rate
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_memory_usage
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_backend_traffic
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_objects
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_uptime
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_transfer_rates
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_expunge
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_threads
RUN ln -s /usr/share/munin/plugins/varnish4_ /etc/munin/plugins/varnish4_bad

ADD start.sh /start.sh

EXPOSE 80
EXPOSE 4949

CMD /start.sh
