# app/jobs/auto_load_jobs.py
import importlib
import pkgutil
from typing import List
from dagster import JobDefinition

from .load_jobs_from_module import load_jobs_from_module


def auto_load_jobs(package_name: str = "jobs") -> List[JobDefinition]:
    """Recursively scans a package and its sub-packages for Dagster jobs."""
    package = importlib.import_module(package_name)
    jobs: List[JobDefinition] = []
    for _, name, is_pkg in pkgutil.iter_modules(package.__path__):
        full_name = f"{package_name}.{name}"
        mod = importlib.import_module(full_name)
        jobs.extend(load_jobs_from_module(mod))
        if is_pkg:
            jobs.extend(auto_load_jobs(full_name))

    return jobs
