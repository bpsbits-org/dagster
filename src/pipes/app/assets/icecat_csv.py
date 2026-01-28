# app/assets/icecat_csv.py
from pathlib import Path
from dagster import asset, get_dagster_logger
from .icecat.IceCatCsv import IceCatCsv


@asset(
    group_name="icecat",
    tags={"group": "icecat"},
    description="Returns IceCat CSV file. If missing tries to download it.",
    required_resource_keys={"icecat_creds"},
)
def icecat_csv(context):
    logger = get_dagster_logger()
    creds = context.resources.icecat_creds
    usr = creds.username
    psw = creds.password
    if not usr or not psw:
        raise ValueError("icecat_user configuration is missing username and/or password")
    ice_cat = IceCatCsv.make(username=usr, password=psw)
    gz_path = ice_cat.get()
    path = Path(gz_path)
    if not path.exists():
        logger.error(f"File was not found: {gz_path}")
        raise FileNotFoundError("File not found")
    size_mb = round(path.stat().st_size / (1024 ** 2), 2)
    logger.info(f"Downloaded IceCat file → {gz_path} ({size_mb} MB)")
    return gz_path


__all__ = ["icecat_csv"]
