# app/sensors/defs.py
from dagster import load_assets_from_package_module
import sensors

ALL_SENSORS = load_assets_from_package_module(sensors)
