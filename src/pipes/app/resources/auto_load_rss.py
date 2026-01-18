# app/resources/auto_load_rss.py
import importlib
import pkgutil
from typing import Dict, Any

from dagster import ResourceDefinition


def auto_load_rss(package_name: str = "resources") -> Dict[str, Any]:
    resources = {}
    package = importlib.import_module(package_name)

    for _, module_name, _ in pkgutil.walk_packages(package.__path__, prefix=f"{package_name}."):
        try:
            module = importlib.import_module(module_name)
        except ImportError:
            continue
        if hasattr(module, '__all__') and len(module.__all__) > 0:
            exported_name = module.__all__[0]
            res = getattr(module, exported_name, None)
        else:
            res = None
            for attr in dir(module):
                if attr.startswith('_'):
                    continue
                obj = getattr(module, attr)
                if isinstance(obj, ResourceDefinition):
                    res = obj
                    exported_name = attr
                    break
        if isinstance(res, ResourceDefinition):
            key = exported_name
            if key in resources:
                raise ValueError(f"Duplicate resource key: {key}")
            resources[key] = res
    return resources
