# assets/config/user_conf.py
from dagster import asset, get_dagster_logger
from box import Box


@asset(
    description="Loads named user configuration as Box (dot-notation friendly)",
    group_name="conf",
    compute_kind="configuration",
    tags={"kind": "admin", "type": "config"},
    required_resource_keys={"user_conf"}
)
def user_conf(context) -> Box:
    """
    Asset that returns the result of the resource 'user_conf'.
    """
    logger = get_dagster_logger()
    conf = context.resources.user_conf
    fields = ", ".join(conf.keys())
    logger.info(f"Retrieved configuration with fields: [{fields}]")
    return conf


__all__ = ["user_conf"]
