# app/resources/defs.py
from .pg.PgDynamicRs import PgDynamicRs
from .auto_load_rss import auto_load_rss

# Hardcoded resources
db_dynamic_rs = PgDynamicRs.configure_at_launch()
RSS_MANUAL = {"db_dynamic": db_dynamic_rs}

# Dynamically loaded resources
RSS_AUTO = auto_load_rss()

# Combine all resources
ALL_RESOURCES = {**RSS_MANUAL, **RSS_AUTO}
