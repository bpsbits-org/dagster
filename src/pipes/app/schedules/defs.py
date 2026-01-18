# app/schedules/defs.py
from dagster import load_assets_from_package_module
import schedules

ALL_SCHEDULES = load_assets_from_package_module(schedules)
