# app/definitions.py
from dagster import Definitions

from jobs.defs import ALL_JOBS
from assets.defs import ALL_ASSETS
from schedules.defs import ALL_SCHEDULES
from sensors.defs import ALL_SENSORS
from resources.defs import ALL_RESOURCES

defs = Definitions(
    jobs=ALL_JOBS,
    assets=ALL_ASSETS,
    schedules=ALL_SCHEDULES,
    sensors=ALL_SENSORS,
    resources=ALL_RESOURCES,
)
