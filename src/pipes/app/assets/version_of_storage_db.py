# app/assets/version_of_storage_db.py
from dagster import asset, get_dagster_logger

from resources.pg.PgStorageRs import PgStorageRs


@asset(
    compute_kind="postgresql",
    group_name="test",
    description="Checks the PostgreSQL version of the main storage database."
)
def version_of_storage_db(db_storage: PgStorageRs):
    logger = get_dagster_logger()

    with db_storage.conf() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT version();")
            db_version = cursor.fetchone()[0]
            logger.info(f"Storage Database Version: {db_version}")

    return db_version


__all__ = ["version_of_storage_db"]
