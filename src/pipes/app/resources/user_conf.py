# app/resources/user_conf.py
from dagster import resource, get_dagster_logger
from box import Box
from .conf.UserConf import UserConf


@resource(
    config_schema={"key": str},
    description="User defined configuration.")
def user_conf(context) -> Box:
    logger = get_dagster_logger()
    key = context.resource_config["key"]
    try:
        config = UserConf.load(key)
        logger.info(f"Loaded configuration '{key}'")
        return config
    except Exception as e:
        logger.error(f"Failed to load configuration '{key}': {str(e)}")
        raise


__all__ = ["user_conf"]
