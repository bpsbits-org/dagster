import importlib
import pkgutil
from dagster import SensorDefinition
from typing import List


# noinspection DuplicatedCode
def auto_load_sensors(package_name: str = "sensors") -> List[SensorDefinition]:
    """Loads sensors automatically."""
    sensors: List[SensorDefinition] = []
    package = importlib.import_module(package_name)
    for _, module_name, _ in pkgutil.walk_packages(package.__path__, prefix=f"{package_name}."):
        module = importlib.import_module(module_name)
        exported_names = getattr(module, '__all__', dir(module))
        for name in exported_names:
            obj = getattr(module, name)
            if isinstance(obj, SensorDefinition):
                sensors.append(obj)

    return sensors
