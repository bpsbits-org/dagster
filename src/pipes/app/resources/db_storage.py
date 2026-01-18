# app/resources/db_storage.py

from dagster import resource
from threading import Lock
from .pg.PgStorageRs import PgStorageRs

_cache_db_storage_cnf = None
_lock_db_storage_cnf = Lock()


@resource(description="The configuration of storage database.")
def db_storage(context):
    global _cache_db_storage_cnf
    if _cache_db_storage_cnf is None:
        with _lock_db_storage_cnf:
            if _cache_db_storage_cnf is None:
                _cache_db_storage_cnf = PgStorageRs.load_conf()

    config = _cache_db_storage_cnf
    return PgStorageRs(
        host=config["host"],
        user=config["user"],
        password=config["password"],
        database=config["database"],
        port=int(config["port"]),
        db_schema=config["db_schema"],
    )


__all__ = ["db_storage"]
