# Dagster Pipes (User Code)
# src/containers/pipes/Dockerfile
FROM python:3.13-slim

ENV DAGSTER_APP_DIR=/opt/dagster/app
ENV DAGSTER_SHARE_DIR=/data/share
WORKDIR "$DAGSTER_APP_DIR"

ENV DGS_PG_SRV=host.containers.internal
ENV DGS_PG_PRT=5432
ENV DGS_PG_DBN=dagster
ENV DGS_PG_SCH=dagster

COPY install.sh "$DAGSTER_APP_DIR"/
RUN bash "${DAGSTER_APP_DIR}/install.sh"

VOLUME /opt/dagster/app
VOLUME /data/share

COPY app/ "$DAGSTER_APP_DIR"/
EXPOSE 4000
HEALTHCHECK --timeout=1s --start-period=3s --interval=3s --retries=20 CMD ["dagster", "api", "grpc-health-check", "-p", "4000"]
CMD ["dagster", "code-server", "start", "-h", "0.0.0.0", "-p", "4000", "-f", "definitions.py"]