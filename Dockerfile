FROM python:3.7.5-slim-stretch

# Install python things
RUN apt-get -y update && \
  apt-get -y upgrade python3 && \
  apt-get install -y --no-install-recommends wget python3-pip python3-numpy python3-scipy && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install nibabel and mysql things
RUN pip3 install --upgrade setuptools
RUN pip3 install --no-cache-dir setuptools nibabel pandas tqdm h5py

# Just mrconvert
RUN \
  wget https://upenn.box.com/shared/static/xg0burjnbk921k9e662yy5wkt02zra4f.gz && \
  tar xvfz xg0burjnbk921k9e662yy5wkt02zra4f.gz && \
  mv mrtrix3 /opt/mrtrix3 && \
  rm xg0burjnbk921k9e662yy5wkt02zra4f.gz

ENV PATH="/opt/mrtrix3/bin:$PATH"

RUN mkdir -p /fixeldb
COPY ./inst/python/fixeldb/ /fixeldb/
RUN pip3 install --no-cache-dir /fixeldb

<<<<<<< HEAD
ENTRYPOINT ["/usr/local/bin/fixeldb_create"]
=======
RUN mkdir -p /inputs

ENTRYPOINT ["fixel-backend-create"]
>>>>>>> develop
