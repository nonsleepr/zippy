FROM centos:centos7.3.1611

# docker build -t zippy -f centos.Dockerfile .

MAINTAINER nonsleepr@gmail.com

RUN yum -y install make
#RUN yum -y makecache && \
#    yum -y install make

WORKDIR /app

RUN curl -Lo /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
    python /tmp/get-pip.py
#COPY requirements.txt /app/requirements.txt
#RUN pip install -r requirements.txt
RUN pip install Flask==0.10.1
RUN pip install Werkzeug==0.11.4
RUN pip install celery==3.1.23

# Soee of the packages below depend on it
RUN pip install Cython==0.24

RUN yum -y install gcc
RUN yum -y install python-devel

# Depends on gcc
RUN pip install bcrypt==2.0.0
RUN pip install primer3-py==0.5.0
RUN pip install reportlab==3.3.0

RUN yum -y install zlib-devel
RUN pip install pysam==0.9.0

