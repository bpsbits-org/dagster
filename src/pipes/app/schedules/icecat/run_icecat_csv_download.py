# app/schedules/icecat/run_icecat_csv_download.py
from dagster import schedule, RunRequest


@schedule(
    cron_schedule="0 4 * * *",
    job_name="download_icecat_csv",
    tags={"group": "icecat"},
)
def run_icecat_csv_download(context):
    """Schedule to download IceCat CSV file."""
    return RunRequest(run_key=None, run_config={})


__all__ = ["run_icecat_csv_download"]
