# app/assets/version_of_dyn_db.py
from dagster import asset, get_dagster_logger
from resources.pg.PgDynamicRs import PgDynamicRs


@asset(
    compute_kind="postgresql",
    group_name="test",
    description="Checks the PostgreSQL version using the dynamically configured connection."
)
def version_of_dyn_db(db_dynamic: PgDynamicRs):
    """Checks the PostgreSQL version using the dynamically configured connection."""
    logger = get_dagster_logger()
    try:
        with db_dynamic.get_db_storage_cn() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT version();")
                db_version = cursor.fetchone()[0]
                logger.info(f"Dynamic Database Version: {db_version}")
        return db_version
    except Exception as e:
        logger.error(f"Failed to connect to dynamic PostgreSQL database: {str(e)}")
        raise


__all__ = ["version_of_dyn_db"]
