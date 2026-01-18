# app/assets/defs.py
from dagster import load_assets_from_package_module
import assets

ALL_ASSETS = load_assets_from_package_module(assets)
