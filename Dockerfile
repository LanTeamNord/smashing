# Use a specific version to be repeatable
FROM phusion/baseimage:0.9.20

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Add a script to run the a smashing app
ADD docker/smashing.sh /etc/service/smashing/run

RUN apt-get update && \
    apt-get -y install nodejs git vim gcc g++ ruby gem ruby-dev make && \
    apt-get -y clean

# Set up the default app
RUN mkdir -p /vol/smashing
COPY . /vol/smashing-src

WORKDIR /vol/smashing-src
RUN gem build smashing.gemspec
RUN gem install ./smashing-1.0.0.gem bundler

WORKDIR /vol/
RUN smashing new smashing && \
    cd /vol/smashing && \
    bundle && \
    mkdir /vol/smashing/config && \
    mv /vol/smashing/config.ru /vol/smashing/config/config.ru && \
    ln -s /vol/smashing/config/config.ru /vol/smashing/config.ru

# Clean up
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define mountable directories
VOLUME ["/vol/smashing/dashboards", "/vol/smashing/jobs", "/vol/smashing/lib-smashing", "/vol/smashing/config", "/vol/smashing/public", "/vol/smashing/widgets", "/vol/smashing/assets"]

ENV PORT 3030
EXPOSE 3030
WORKDIR /vol/smashing