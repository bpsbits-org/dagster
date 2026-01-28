# app/jobs/load_jobs_from_module.py
import inspect
from dagster import JobDefinition
from typing import List


def load_jobs_from_module(module) -> List[JobDefinition]:
    """Scans a module for Dagster JobDefinitions and returns them as a list."""
    jobs: List[JobDefinition] = []
    if hasattr(module, "__all__"):
        for name in module.__all__:
            obj = getattr(module, name)
            if isinstance(obj, JobDefinition):
                jobs.append(obj)
    else:
        for name, obj in inspect.getmembers(module):
            if isinstance(obj, JobDefinition):
                jobs.append(obj)

    return jobs
