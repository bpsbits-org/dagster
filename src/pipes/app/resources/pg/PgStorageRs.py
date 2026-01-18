# app/resources/pg/PgStorageRs.py
from .DagsterDb import DagsterDb
from .PgConnCnf import PgConnCnf
from contextlib import contextmanager
from dagster import ConfigurableResource
from psycopg2.extras import Json
import psycopg2


class PgStorageRs(PgConnCnf, ConfigurableResource):

    @contextmanager
    def conf(self):
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

    @staticmethod
    def load_conf():
        try:
            with DagsterDb.conn() as conn:
                with conn.cursor() as cur:
                    cur.execute("select get_user_conf('db_storage')")
                    row = cur.fetchone()
                    if not row or not row[0]:
                        raise ValueError("No db_storage config found")
                    return row[0]
        finally:
            conn.close()

    def save(self):
        new_conf = {
            "host": self.host,
            "user": self.user,
            "password": self.password,
            "database": self.database,
            "port": self.port,
            "db_schema": self.db_schema
        }
        with DagsterDb.conn() as dg_conn:
            with dg_conn.cursor() as cur:
                cur.execute("select set_user_conf(%s, %s)", ('db_storage', Json(new_conf)))
            dg_conn.commit()
