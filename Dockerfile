FROM ubuntu:12.04
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
&& apt-get update \
&& apt-get upgrade -y \
&& apt-get install -y git libtool autoconf pkg-config build-essential g++ bison flex libssl-dev automake libboost-all-dev libevent-dev supervisor \
&& rm -rf /var/lib/apt/lists/*
ENV thrift_src /usr/local/src/thrift
RUN git clone https://github.com/apache/thrift.git $thrift_src \
&& cd $thrift_src && git checkout 0.9.1 \
&& ./bootstrap.sh && ./configure && make && make install
RUN cd $thrift_src/contrib/fb303 \
&& ./bootstrap.sh \
&& ./configure CPPFLAGS="-DHAVE_INTTYPES_H -DHAVE_NETINET_IN_H" \
&& make && make install
ENV scribe_src /usr/local/src/scribe
RUN git clone https://github.com/facebook/scribe.git $scribe_src \
&& cd $scribe_src && ./bootstrap.sh \
&& ./configure CPPFLAGS="-DHAVE_INTTYPES_H -DHAVE_NETINET_IN_H -DBOOST_FILESYSTEM_VERSION=2" LIBS="-lboost_system -lboost_filesystem" \
&& make && make install
ENV LD_LIBRARY_PATH /usr/local/lib
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib" >> /etc/profile
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 1463
CMD ["/usr/bin/supervisord"]
