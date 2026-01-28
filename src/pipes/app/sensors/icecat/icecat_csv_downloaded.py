from dagster import run_status_sensor, DagsterRunStatus, RunRequest, RunsFilter, SkipReason

from jobs.icecat.download_icecat_csv import download_icecat_csv
from jobs.icecat.parse_icecat_csv_into_db import parse_icecat_csv_into_db


@run_status_sensor(
    run_status=DagsterRunStatus.SUCCESS,
    monitored_jobs=[download_icecat_csv],
    request_job=parse_icecat_csv_into_db,
    tags={"group": "icecat"},
    minimum_interval_seconds=60,
)
def icecat_csv_downloaded(context):
    """Sensor that triggers downstream when the CSV download job completes successfully."""
    instance = context.instance
    in_progress_statuses = [DagsterRunStatus.STARTED, DagsterRunStatus.QUEUED, DagsterRunStatus.STARTING, ]
    runs_filter = RunsFilter(job_name=parse_icecat_csv_into_db.name, statuses=in_progress_statuses)
    active_runs = instance.get_runs(filters=runs_filter, limit=1)
    if len(active_runs) > 0:
        return SkipReason(f"Job {parse_icecat_csv_into_db.name} is already active")
    run_id = context.dagster_run.run_id
    return RunRequest(run_key=run_id, tags={"parent_run_id": run_id})
