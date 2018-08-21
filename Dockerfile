FROM centos:centos7.3.1611

# docker build -t zippy2 -f centos.Dockerfile .

MAINTAINER nonsleepr@gmail.com

RUN yum -y install epel-release && \
    yum -y install make gcc python-devel unzip zlib-devel perl mysql nginx

# bcrypt, primer3-py, reportlab and pysam depend on gcc python-devel and make
WORKDIR /app
COPY . /app/
RUN make install

# This would be mounted by docker-compose
#VOLUME /usr/local/zippy/resources/

# Server
#RUN pip install gunicorn
