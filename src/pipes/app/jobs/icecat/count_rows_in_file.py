# app/jobs/icecat/count_rows_in_file.py
from dagster import get_dagster_logger


def count_rows_in_file(csv_path: str) -> int:
    logger = get_dagster_logger()
    try:
        with open(csv_path, "rb") as f:
            total_lines = sum(1 for _ in f)
            rows_total = total_lines - 1  # Subtract 1 for the header
        logger.info(f"Total rows found: {rows_total:,}")
    except Exception as e:
        logger.error(f"Failed during row count: {e}")
        raise
    if rows_total <= 0:
        logger.warning("Empty file or only header detected")
    return rows_total
