# app/assets/icecat/IceCatCsv.py
from dagster import get_dagster_logger
from datetime import datetime, timedelta
from pathlib import Path
import gzip
import os
import requests
import shutil
from shutil import copyfile
import tempfile


class IceCatCsv:
    """Loads the CSV file from IceCat."""

    url = "https://data.icecat.biz/export/freexml.int/INT/files.index.csv.gz"
    usr: str
    psw: str
    dir = "/data/share/in"
    zip = "icecat.data.csv.gz"
    csv = "icecat.data.csv"
    out = 24

    def __init__(self, usr: str, psw: str):
        self.usr = usr
        self.psw = psw
        self.logger = get_dagster_logger()

    @staticmethod
    def mkdir_target():
        target_dir = Path(IceCatCsv.dir)
        target_dir.mkdir(parents=True, exist_ok=True)

    @staticmethod
    def make(username: str, password: str) -> 'IceCatCsv':
        """Creates a new IceCatCsv instance."""
        return IceCatCsv(usr=username, psw=password)

    def download(self) -> str:
        """Downloads the CSV file from IceCat."""
        self.logger.info(f"Starting IceCat download (user: {self.usr[:8]}...)")  # ← improved

        self.mkdir_target()
        with requests.get(self.url, auth=(self.usr, self.psw), stream=True, timeout=90) as r:
            r.raise_for_status()
            downloaded = 0
            temp_file_obj = tempfile.NamedTemporaryFile(delete=False, suffix=".gz", mode="wb")
            temp_file = temp_file_obj.name
            temp_file_obj.close()
            with open(temp_file, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)
                    downloaded += len(chunk)
            mb = downloaded / (1024 * 1024)
            self.logger.info(f"Downloaded: {mb:.1f} MB")
        path_temp_file = Path(temp_file)
        path_persistent = self.path_zip()
        copyfile(path_temp_file, path_persistent)
        os.remove(temp_file)
        self.logger.info(f"Persistent file: {path_persistent}")
        return str(path_persistent)

    @staticmethod
    def path_zip():
        """Returns the path to the zipped CSV file."""
        return Path(f"{IceCatCsv.dir}/{IceCatCsv.zip}")

    @staticmethod
    def path_csv():
        """Returns the path to the CSV file."""
        return Path(f"{IceCatCsv.dir}/{IceCatCsv.csv}")

    @staticmethod
    def zip_exists() -> bool:
        """Checks if the zipped CSV file exists."""
        path = IceCatCsv.path_zip()
        return path.exists()

    @staticmethod
    def exists() -> bool:
        """Checks if the CSV file exists."""
        path = IceCatCsv.path_csv()
        return path.exists()

    @staticmethod
    def is_file_outdated(path: Path) -> bool:
        if not path.exists():
            return True
        mtime = path.stat().st_mtime
        mod_time = datetime.fromtimestamp(mtime)
        cutoff = datetime.now() - timedelta(hours=IceCatCsv.out)
        return mod_time < cutoff

    @staticmethod
    def is_zip_outdated() -> bool:
        """Checks if the zipped CSV file is outdated."""
        path = IceCatCsv.path_zip()
        is_outdated = IceCatCsv.is_file_outdated(path)
        if is_outdated and path.exists():
            os.remove(path)
        return is_outdated

    @staticmethod
    def is_csv_outdated() -> bool:
        """Checks if the CSV file is outdated."""
        path = IceCatCsv.path_csv()
        is_outdated = IceCatCsv.is_file_outdated(path)
        if is_outdated and path.exists():
            os.remove(path)
        return is_outdated

    def get_zipped(self) -> str:
        """Returns the path to the CSV file. If the file is outdated or missing, downloads it first."""
        if not self.is_zip_outdated():
            file_path = str(self.path_zip())
            self.logger.info(f"Compressed file exists: {file_path}")
            return file_path
        return self.download()

    def download_and_unzip(self) -> str:
        """Downloads and extracts the IceCat CSV file."""
        self.mkdir_target()
        zipped_path = self.get_zipped()
        temp_file_obj = tempfile.NamedTemporaryFile(delete=False, suffix=".csv")
        csv_file = temp_file_obj.name
        temp_file_obj.close()
        try:
            with gzip.open(zipped_path, "rb") as f_in:
                with open(csv_file, "wb") as f_out:
                    shutil.copyfileobj(f_in, f_out)
            self.logger.info("Extraction complete.")
            size_mb = os.path.getsize(csv_file) / (1024 * 1024)
            self.logger.info(f"Path: {csv_file}")
            self.logger.info(f"Size ({size_mb:.1f} MB):")
            csv_path = self.path_csv()
            copyfile(csv_file, csv_path)
        finally:
            if os.path.exists(csv_file):
                os.unlink(csv_file)
        return str(csv_path)

    def get(self) -> str:
        self.logger.info("Checking for CSV file...")
        if not self.is_csv_outdated():
            self.logger.info("File exists.")
            return str(self.path_csv())
        return self.download_and_unzip()
