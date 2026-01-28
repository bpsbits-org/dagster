from dagster import get_dagster_logger


def get_prod_id(row: dict, row_id: int) -> str:
    logger = get_dagster_logger()
    prod_id = row.get("product_id", "").strip()
    if not prod_id:
        prod_id = f"row_{row_id:07d}"
        logger.warning(f"Empty product_id in row {row_id} → using {prod_id}")
    return prod_id
