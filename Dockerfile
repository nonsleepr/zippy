FROM centos:7

MAINTAINER nonsleepr@gmail.com

RUN yum -y install make

WORKDIR /app
COPY . /app/
RUN make dependencies
RUN make install
#RUN make resources

# This would be mounted by docker-compose
VOLUME [ "/var/local/zippy/resources/" ]

CMD /var/local/zippy/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 zippy:app
