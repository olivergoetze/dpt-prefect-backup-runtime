FROM prefecthq/prefect:3.4.1-python3.11
ENV RESTIC_VERSION=0.17.0
ENV RUN_USER=nobody
ENV RUN_GROUP=0

# extra pip packages for Dask on Kubernetes and S3
RUN pip install cloudpathlib[s3] s3fs prefect-dask

# base Python dependencies
RUN pip install python-dotenv

ADD https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2 /tmp/restic/restic.bz2
RUN bunzip2 /tmp/restic/restic.bz2
RUN mkdir --parents /opt/restic
RUN mv /tmp/restic/restic /opt/restic/restic
RUN chmod +x /opt/restic/restic
RUN chown ${RUN_USER}:${RUN_GROUP} /opt/restic/restic
RUN rm -rf /tmp/restic

# NOTE: hier werden lediglich die übergeordneten Verzeichnisse backup_target und backup_padding erstellt. Diese dienen im Docker-Container als Mount-Points für die Kubernetes-PersistentVolumes. Die Unterverzeichnisse (/backup_target/delivery_data, /backup_padding/delivery_data, ...) müssen zur Laufzeit des Docker-Containers (Prefect-Flow) erstellt werden, da erst dann die PVs gemountet sind.
RUN mkdir /opt/backup_target
RUN mkdir /opt/backup_padding

RUN mkdir /.prefect
RUN chgrp -R 0 /.prefect && \
         chmod -R g=u /.prefect

RUN chgrp -R 0 /opt && \
         chmod -R g=u /opt

USER 1001