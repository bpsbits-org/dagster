# app/jobs/download_icecat_csv.py
from pathlib import Path
from dagster import job, op, get_dagster_logger, Output, build_asset_context

from assets.icecat_csv import icecat_csv
from resources.icecat_creds import icecat_creds


class ICCsvMeta:
    """Metadata for the CSV file download job."""
    path: str
    success: bool
    size_mb: str

    def update(self):
        """Updates the metadata based on the current state of the CSV file."""
        path = Path(self.path)
        self.success = path.exists()
        self.size_mb = f"{(path.stat().st_size / (1024 ** 2)):.2f}" if path.exists() else "0.00"

    def to_meta(self):
        """Returns the metadata as a dictionary."""
        self.update()
        return Output(
            {"path": self.path,
             "success": self.success,
             "size_mb": self.size_mb}
        )

    @staticmethod
    def descriptions():
        """Returns descriptions of the metadata fields."""
        return {
            "path": "Path of CSV file",
            "success": "True if CSV file exists",
            "size_mb": "Size of CSV file in MB"
        }


@op(required_resource_keys={"icecat_creds"}, tags={"group": "icecat"}, )
def dnl_icecat_csv(context) -> Output:
    """Downloads the latest version of IceCat CSV from IceCat's website"""
    asset_context = build_asset_context(resources={"icecat_creds": context.resources.icecat_creds})
    mt = ICCsvMeta()
    mt.path = str(icecat_csv(asset_context))
    return mt.to_meta()


@job(description="Downloads IceCat CSV",
     tags={"group": "icecat"},
     metadata=ICCsvMeta.descriptions(),
     resource_defs={"icecat_creds": icecat_creds}, )
def download_icecat_csv():
    """Job to download IceCat CSV data."""
    logger = get_dagster_logger()
    logger.info("Trying to download IceCat CSV...")
    dnl_icecat_csv()


__all__ = ["download_icecat_csv"]
