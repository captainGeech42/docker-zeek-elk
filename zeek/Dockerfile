# based on https://github.com/zeek/zeek-docker/blob/master/master.Dockerfile

##################
### BUILD ZEEK ###
##################

FROM debian:buster AS builder

# Install dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python3-dev python-dev swig zlib1g-dev git

# Checkout Zeek
WORKDIR /tmp/build
RUN git clone --recursive https://github.com/zeek/zeek.git

# Build Zeek (this will take a while)
WORKDIR /tmp/build/zeek
RUN ./configure
RUN make
RUN make install

################
### RUN ZEEK ###
################

FROM debian:buster
ENV PATH /usr/local/zeek/bin:$PATH

# Install dependencies
RUN apt-get update \
    && apt-get -y install --no-install-recommends libpcap0.8 libssl1.1 libmaxminddb0 python2.7-minimal python3-minimal python3-pip inotify-tools git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy in Zeek
COPY --from=builder /usr/local/zeek /usr/local/zeek

# Install zkg
RUN pip3 install setuptools
RUN pip3 install zkg

# Configure new user
RUN useradd -U -m zeek
RUN chown -R zeek:zeek /usr/local/zeek

# Setup directories for PCAP processing
WORKDIR /home/zeek
ARG ZEEK_INDIR
ARG ZEEK_OUTDIR
ARG ZEEK_LOGDIR
ENV ZEEK_INDIR=${ZEEK_INDIR}
ENV ZEEK_OUTDIR=${ZEEK_OUTDIR}
ENV ZEEK_LOGDIR=${ZEEK_LOGDIR}
RUN mkdir ${ZEEK_INDIR}
RUN mkdir ${ZEEK_OUTDIR}
RUN mkdir ${ZEEK_LOGDIR}
RUN chown zeek:zeek ${ZEEK_INDIR}
RUN chown zeek:zeek ${ZEEK_OUTDIR}
RUN chown zeek:zeek ${ZEEK_LOGDIR}
COPY run.sh .
RUN chmod +x run.sh

# Switch to non-root user
USER zeek

# Install zeek packages
RUN echo | zkg autoconfig
RUN zkg install --force ja3 hassh

# Add Zeek config
COPY local.zeek /tmp/local.zeek
RUN cat /tmp/local.zeek >> /usr/local/zeek/share/zeek/site/local.zeek

# Run script
CMD ./run.sh
