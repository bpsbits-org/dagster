# resources/pg/DagsterDb.py
from contextlib import contextmanager
from functools import lru_cache
from resources.pg.PgConnCnf import PgConnCnf
import os
import psycopg2


class DagsterDb:
    """Utility class for accessing Dagster PostgreSQL connection configuration."""

    @staticmethod
    @lru_cache(maxsize=1)
    def conf() -> PgConnCnf:
        """Returns the PostgreSQL connection configuration."""
        return PgConnCnf(
            host=os.getenv("DGS_PG_SRV"),
            port=int(os.getenv("DGS_PG_PRT", "5432")),
            user=os.getenv("DGS_PG_USR"),
            password=os.getenv("DGS_PG_PSW"),
            database=os.getenv("DGS_PG_DBN"),
            db_schema=os.getenv("DGS_PG_SCH") or "dagster"
        )

    @staticmethod
    @contextmanager
    def conn():
        """Returns the PostgreSQL connection."""
        cnf = DagsterDb.conf()
        conn = psycopg2.connect(
            host=cnf.host,
            user=cnf.user,
            password=cnf.password,
            dbname=cnf.database,
            port=cnf.port,
            options=f"-c search_path={cnf.db_schema}"
        )
        try:
            yield conn
        finally:
            conn.close()
