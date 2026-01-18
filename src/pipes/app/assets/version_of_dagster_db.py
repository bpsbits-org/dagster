from dagster import asset, get_dagster_logger

from resources.pg.DagsterDb import DagsterDb


@asset(
    compute_kind="postgresql",
    group_name="test",
    description="Checks the version of Dagster database."
)
def version_of_dagster_db():
    """Checks the version of Dagster database."""
    logger = get_dagster_logger()
    try:
        with DagsterDb.conn() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT version();")
                db_version = cursor.fetchone()[0]
                logger.info(f"Dagster Database Version: {db_version}")
        return db_version
    except Exception as e:
        logger.error(f"Failed to connect to Dagster database: {str(e)}")
        raise


__all__ = ["version_of_dagster_db"]
