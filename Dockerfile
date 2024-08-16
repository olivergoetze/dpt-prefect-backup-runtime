FROM prefecthq/prefect:2.16.3-python3.11
ENV RESTIC_VERSION=0.16.5
ENV RUN_USER=nobody
ENV RUN_GROUP=0

# extra pip packages for Dask on Kubernetes and S3
RUN pip install cloudpathlib[s3] prefect-dask

# base Python dependencies
RUN pip install python-dotenv

ADD https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2 /tmp/restic/restic.bz2
RUN bunzip2 /tmp/restic/restic.bz2
RUN mkdir --parents /opt/restic
RUN mv /tmp/restic/restic /opt/restic/restic
RUN chmod +x /opt/restic/restic
RUN chown ${RUN_USER}:${RUN_GROUP} /opt/restic/restic
RUN rm -rf /tmp/restic

RUN mkdir --parents /backup_target/delivery_data
RUN mkdir --parents /backup_target/result_data
RUN mkdir --parents /backup_target/postgres
RUN mkdir --parents /backup_target/typesense
RUN mkdir --parents /backup_padding/delivery_data
RUN mkdir --parents /backup_padding/result_data
RUN mkdir --parents /backup_padding/postgres
RUN mkdir --parents /backup_padding/typesense