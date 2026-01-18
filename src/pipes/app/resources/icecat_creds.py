# resources/icecat_creds.py
from dagster import resource
from box import Box


@resource(description="IceCat credentials.")
def icecat_creds(context) -> Box:
    from .conf.UserConf import UserConf
    return UserConf.load("icecat_user")
