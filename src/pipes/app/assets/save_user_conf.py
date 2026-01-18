# assets/config/save_user_conf.py
from dagster import asset, Field, get_dagster_logger
from box import Box
from psycopg2.extras import Json

from resources.pg.DagsterDb import DagsterDb


@asset(
    description="Saves named configuration as JSON in database.",
    group_name="conf",
    compute_kind="configuration",
    tags={"kind": "admin", "type": "config", "access": "sensitive"},
    config_schema={
        "key": Field(str, description="Name/identifier of the configuration (e.g. 'dashboard', 'trading', 'ui_prefs')", ),
        "value": Field(dict, description="Configuration content as a Python dictionary (will be stored as JSONB)", ),
    }
)
def save_user_conf(context) -> str:
    """
    Saves named configuration.
    """
    logger = get_dagster_logger()

    cfg = context.op_config
    key = cfg["key"]
    raw_value = cfg["value"]

    # Convert to Box for nicer handling & validation
    try:
        config_value = Box(raw_value)
    except Exception as e:
        raise ValueError(f"Invalid configuration structure for '{key}': {str(e)}")

    try:
        with DagsterDb.conn() as conn:
            with conn.cursor() as cur:
                cur.execute("select set_user_conf(%s, %s)", (key, Json(config_value)))
            conn.commit()
        saved_keys = list(config_value.keys())
        preview = config_value.to_json(indent=2, sort_keys=True)
        summary = (
            f"User configuration **{key}** saved successfully ✓\n\n"
            f"→ Saved fields: {', '.join(saved_keys)}\n"
            f"→ Preview:\n{preview[:400]}{'...' if len(preview) > 400 else ''}\n\n"
            "You can now load it using: UserConf.load(\"{key}\")"
        )
        logger.info(summary)
        return summary

    except Exception as e:
        logger.error(f"Failed to save user configuration '{key}': {str(e)}")
        raise

__all__ = ["save_user_conf"]