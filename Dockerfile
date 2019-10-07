FROM mariadb:10.4.8-bionic

# Install python things
RUN apt-get -y update && \
  apt-get -y upgrade python3 && \
  apt-get install -y --no-install-recommends python3-pip python3-numpy python3-scipy && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nibabel and mysql things
RUN pip3 install --upgrade setuptools
RUN pip3 install --no-cache-dir setuptools nibabel pandas tqdm SQLAlchemy argparse
RUN pip3 install --no-cache-dir mysql-connector

# THIS DOESN'T WORK
ENV MYSQL_USER 'fixeluser'  \
    MYSQL_PASSWORD'fixels' \
    MYSQL_DATABASE 'fixeldb'
    # MYSQL_ROOT_PASSWORD 'my-secret-pw'

RUN mkdir -p /fixeldb
COPY ./fixeldb/* /fixeldb/
# Install mrtrix3 from source
# ARG MRTRIX_SHA=5d6b3a6ffc6ee651151779539c8fd1e2e03fad81
# ENV PATH="/opt/mrtrix3-latest/bin:$PATH"
# RUN apt-get update -qq \
#     && apt-get install -y -q --no-install-recommends \
#            g++ \
#            gcc \
#            libeigen3-dev \
#            libqt5svg5* \
#            make \
#            python \
#            python-numpy \
#            zlib1g-dev \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
#     && cd /opt \
#     && curl -sSLO https://github.com/MRtrix3/mrtrix3/archive/${MRTRIX_SHA}.zip \
#     && unzip ${MRTRIX_SHA}.zip \
#     && mv mrtrix3-${MRTRIX_SHA} /opt/mrtrix3-latest \
#     && rm ${MRTRIX_SHA}.zip \
#     && cd /opt/mrtrix3-latest \
#     && ./configure \
#     && echo "Compiling MRtrix3 ..." \
#     && ./build
