# based on https://github.com/zeek/zeek-docker/blob/master/master.Dockerfile

##################
### BUILD ZEEK ###
##################

FROM debian:buster AS builder

# Install dependencies
RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev git

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
    && apt-get -y install --no-install-recommends libpcap0.8 libssl1.0.2 libmaxminddb0 python2.7-minimal python3-minimal python3-pip inotify-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy in Zeek
COPY --from=builder /usr/local/zeek /usr/local/zeek

# Install zkg
RUN pip3 install zkg

# Configure new user
RUN useradd -U -m zeek
RUN chown -R zeek:zeek /usr/local/zeek

# Setup directories for PCAP processing
WORKDIR /home/zeek
RUN mkdir pcaps_to_process
RUN mkdir finished_pcaps
RUN mkdir /zeek_logs
RUN chown zeek:zeek pcaps_to_process
RUN chown zeek:zeek finished_pcaps
RUN chown zeek:zeek /zeek_logs

# Switch to non-root user
USER zeek

# Install zeek packages
RUN zkg autoconfig
RUN zkg install ja3
RUN zkg install hassh

# Add Zeek config
COPY local.zeek /tmp/local.zeek
RUN cat /tmp/local.zeek >> /usr/local/zeek/share/zeek/site/local.zeek

# Run script
COPY run.sh .
RUN chmod +x run.sh
CMD ./run.sh