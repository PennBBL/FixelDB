FROM mariadb:10.4.8-bionic

# Install python things
RUN apt-get -y update && \
  apt-get -y upgrade python3 && \
  apt-get install -y --no-install-recommends wget python3-pip python3-numpy python3-scipy && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nibabel and mysql things
RUN pip3 install --upgrade setuptools
RUN pip3 install --no-cache-dir setuptools nibabel pandas tqdm SQLAlchemy argparse pymysql
RUN pip3 install --no-cache-dir mysql-connector

# THIS DOESN'T WORK
ENV MYSQL_USER 'fixeluser'  \
    MYSQL_PASSWORD'fixels' \
    MYSQL_DATABASE 'fixeldb'
    # MYSQL_ROOT_PASSWORD 'my-secret-pw'

# Just mrconvert
RUN \
  wget https://upenn.box.com/shared/static/xg0burjnbk921k9e662yy5wkt02zra4f.gz && \
  tar xvfz xg0burjnbk921k9e662yy5wkt02zra4f.gz && \
  mv mrtrix3 /opt/mrtrix3
ENV PATH="/opt/mrtrix3/bin:$PATH"

RUN mkdir -p /fixeldb
COPY . /fixeldb/
RUN pip3 install --no-cache-dir /fixeldb
