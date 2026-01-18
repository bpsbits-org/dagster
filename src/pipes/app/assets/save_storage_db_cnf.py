# app/assets/save_storage_db_cnf.py
from dagster import asset, get_dagster_logger
from dagster import Field

from resources.pg.PgStorageRs import PgStorageRs


@asset(
    description="Saves the configuration of storage db",
    group_name="conf",
    compute_kind="configuration",
    tags={"kind": "admin"},
    config_schema={
        "host": Field(str, description="Database host"),
        "port": Field(int, default_value=5432, description="Database port"),
        "user": Field(str, description="Database user"),
        "password": Field(str, description="Database password"),
        "database": Field(str, description="Database name"),
        "db_schema": Field(str, default_value="public", description="Schema to use")
    }
)
def save_storage_db_cnf(context):
    logger = get_dagster_logger()
    cfg = context.op_config
    temp_storage = PgStorageRs(
        host=cfg["host"],
        port=cfg["port"],
        user=cfg["user"],
        password=cfg["password"],
        database=cfg["database"],
        db_schema=cfg["db_schema"]
    )
    temp_storage.save()
    summary = (
        "New storage database configuration saved successfully!\n\n"
        f"• Host:     {temp_storage.host}:{temp_storage.port}\n"
        f"• Database: {temp_storage.database}\n"
        f"• User:     {temp_storage.user}\n"
        f"• Schema:   {temp_storage.db_schema}\n\n"
        "→ **Restart the Dagster process** (or wait for new run in serverless) to use the new connection."
    )
    logger.info(summary)
    return summary
