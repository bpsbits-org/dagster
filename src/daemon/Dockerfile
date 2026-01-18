# Dagster Daemon
# src/containers/daemon/Dockerfile
FROM python:3.13-slim

ENV DAGSTER_HOME=/opt/dagster/dagster_home

ENV DGS_CODE_HOST=host.containers.internal
ENV DGS_CODE_PORT=4000
ENV DGS_CODE_LOCATION_NAME=pipes
ENV DGS_PG_SRV=host.containers.internal
ENV DGS_PG_PRT=5432
ENV DGS_PG_DBN=dagster
ENV DGS_PG_SCH=dagster

WORKDIR "$DAGSTER_HOME"

COPY install.sh dagster.yaml workspace.tpl.yaml entrypoint.sh "$DAGSTER_HOME"/

RUN bash "${DAGSTER_HOME}/install.sh"

ENTRYPOINT ["/opt/dagster/dagster_home/entrypoint.sh"]
CMD ["dagster-daemon", "run"]