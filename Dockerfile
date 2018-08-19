FROM centos:centos7.3.1611

# docker build -t zippy2 -f centos.Dockerfile .

MAINTAINER nonsleepr@gmail.com

RUN yum -y install make gcc Cython python-devel unzip zlib-devel perl

# Install pip
# Alternative to `yum -y install python-pip`
RUN curl -Lo /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python /tmp/get-pip.py && \
    rm /tmp/get-pip.py

# Install bowtie to /usr/local/bin/
RUN curl -Lo /tmp/bowtie2-2.3.4.2-linux-x86_64.zip \
      https://newcontinuum.dl.sourceforge.net/project/bowtie-bio/bowtie2/2.3.4.2/bowtie2-2.3.4.2-linux-x86_64.zip && \
    cd /tmp/ && \
    unzip bowtie2-2.3.4.2-linux-x86_64.zip && \
    mv bowtie2-2.3.4.2-linux-x86_64/bowtie2* /usr/local/bin/ && \
    rm -rf bowtie2-2.3.4.2*


# bcrypt, primer3-py, reportlab and pysam depend on gcc python-devel and make
WORKDIR /app
COPY setup.py /app/
COPY zippy /app/zippy
RUN pip install .

COPY run.py /app/

CMD python /app/run.py

# Zippy data

RUN mkdir -p /var/local/zippy/resources && \
    mkdir -p /var/local/zippy/uploads && \
    mkdir -p /var/local/zippy/results && \
	  touch /var/local/zippy/zippy.sqlite && \
	  touch /var/local/zippy/zippy.log && \
	  touch /var/local/zippy/.blacklist.cache

# This would be mounted by docker-compose
#VOLUME /usr/local/zippy/resources/
