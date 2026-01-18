# resources/pg/PgConnCnf.py
from dagster import Config


class PgConnCnf(Config):
    host: str
    user: str
    password: str
    database: str
    port: int = 5432
    db_schema: str = "public"
