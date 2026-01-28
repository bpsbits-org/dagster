import importlib
import pkgutil
from dagster import ScheduleDefinition
from typing import List


# noinspection DuplicatedCode
def auto_load_sch(package_name: str = "schedules") -> List[ScheduleDefinition]:
    """Loads schedules automatically."""
    schedules: List[ScheduleDefinition] = []
    package = importlib.import_module(package_name)
    for _, module_name, _ in pkgutil.walk_packages(package.__path__, prefix=f"{package_name}."):
        module = importlib.import_module(module_name)
        names = getattr(module, '__all__', dir(module))
        for name in names:
            obj = getattr(module, name)
            if isinstance(obj, ScheduleDefinition):
                schedules.append(obj)
    return schedules
