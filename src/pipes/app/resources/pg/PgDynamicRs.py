# app/resources/pg/PgDynamicRs.py
from .PgConnCnf import PgConnCnf
from contextlib import contextmanager
from dagster import ConfigurableResource
import psycopg2


class PgDynamicRs(PgConnCnf, ConfigurableResource):

    @contextmanager
    def get_db_storage_cn(self):
        conn = psycopg2.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            dbname=self.database,
            port=self.port,
            options=f"-c search_path={self.db_schema}"
        )
        try:
            yield conn
        finally:
            conn.close()
