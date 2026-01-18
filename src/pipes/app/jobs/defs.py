# app/jobs/defs.py
import inspect
from dagster import JobDefinition
from . import parse_icecat_csv  # Import your job modules here


def load_jobs_from_module(module):
    """
    Scans a module for Dagster JobDefinitions and returns them as a list.
    """
    jobs = []
    for name, obj in inspect.getmembers(module):
        if isinstance(obj, JobDefinition):
            jobs.append(obj)
    return jobs


# Dynamically gather all jobs from the parse_icecat_csv module
ALL_JOBS = load_jobs_from_module(parse_icecat_csv)
