FROM openjdk:8-slim
MAINTAINER Jishu Xu <jishu.xu@gmail.com>

# install library

RUN apt-get update && apt-get install -y \
	bzip2 \
	g++ \
	libbz2-dev \
	liblzma-dev \
	make \
	ncurses-dev \
	wget \
	zlib1g-dev \
	git \
	build-essential \
	ca-certificates \
	libncurses5-dev \
	libncursesw5-dev \
	&& rm -rf /var/lib/apt/lists/*
 

ENV SAMTOOLS_INSTALL_DIR=/opt/samtools

WORKDIR /tmp
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 && \
tar --bzip2 -xf samtools-1.9.tar.bz2

WORKDIR /tmp/samtools-1.9
RUN ./configure --enable-plugins --prefix=$SAMTOOLS_INSTALL_DIR && \
make all all-htslib && \
make install install-htslib
RUN ln -s $SAMTOOLS_INSTALL_DIR/bin/samtools /usr/bin/samtools && \
rm -rf /tmp/samtools-1.9

WORKDIR /tmp
# Setup ENV variables
ENV \
SNPEFF_VERSION=4_3t \
SNPEFF_HOME=/opt/snpEff
# Install snpEff
RUN \
wget --quiet -O snpEff_v${SNPEFF_VERSION}_core.zip \
http://downloads.sourceforge.net/project/snpeff/snpEff_v${SNPEFF_VERSION}_core.zip \
&& unzip snpEff_v${SNPEFF_VERSION}_core.zip -d /opt/ \
&& rm snpEff_v${SNPEFF_VERSION}_core.zip

#Download database
ENV GENOME="GRCh38.86"
# Download Genome
RUN java -jar $SNPEFF_HOME/snpEff.jar download $GENOME

#install bcftools
ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools
WORKDIR /tmp
RUN wget https://github.com/samtools/bcftools/releases/download/1.9/bcftools-1.9.tar.bz2 && \
tar --bzip2 -xf bcftools-1.9.tar.bz2

WORKDIR /tmp/bcftools-1.9
RUN make prefix=$BCFTOOLS_INSTALL_DIR && \
make prefix=$BCFTOOLS_INSTALL_DIR install

ENV BCFTOOLS_PLUGINS=/opt/bcftools/plugins

WORKDIR /
RUN ln -s $BCFTOOLS_INSTALL_DIR/bin/bcftools /usr/bin/bcftools && \
rm -rf /tmp/bcftools-1.9

# install umi-tools
ARG PACKAGE_VERSION=0.5.5
ARG DEBIAN_FRONTEND=noninteractive


RUN apt-get update && \
apt-get install --yes python-pip  && \
pip install --upgrade pip && \
rm -rf /var/lib/apt/lists/*

RUN pip install umi-tools && \
rm -rf /var/lib/apt/lists/*


WORKDIR /
