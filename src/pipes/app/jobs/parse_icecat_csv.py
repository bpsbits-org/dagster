# app/jobs/parse_icecat_csv.py
import shutil

from dagster import job, op, get_dagster_logger, Output, Config
from pydantic import Field
from pathlib import Path
import csv
import json

from assets.icecat_csv import icecat_csv


class ParserConf(Config):
    """Configuration for the parse_csv_to_json op."""
    output_dir: str = Field(
        default="/data/share/out/icecat/parsed",
        description="Directory where parsed JSON files will be written"
    )
    cleanup: bool = Field(
        default=True,
        description="Whether to remove the previous JSON files before parsing"
    )


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


def get_prod_id(row: dict, row_id: int) -> str:
    logger = get_dagster_logger()
    prod_id = row.get("product_id", "").strip()
    if not prod_id:
        prod_id = f"row_{row_id:07d}"
        logger.warning(f"Empty product_id in row {row_id} → using {prod_id}")
    return prod_id


def make_output_dir(config: ParserConf) -> Path:
    logger = get_dagster_logger()
    path_output = Path(config.output_dir)
    if config.cleanup and path_output.exists():
        logger.info("Cleaning up output directory...")
        shutil.rmtree(str(path_output), ignore_errors=True)
        logger.info("Cleaning of output directory completed.")
    path_output.mkdir(parents=True, exist_ok=True)
    return path_output


@op(description="Parses given IceCat CSV file → one JSON per product using product_id")
def parse_csv_to_json(config: ParserConf, csv_path: str):
    """
    Parses large IceCat CSV → one JSON per product.
    Two-pass version: first counts total rows, then processes with percentage progress.
    Uses csv.reader to avoid silent row dropping on bad quoting.
    """
    logger = get_dagster_logger()
    files_count = 0
    rows_processed = 0
    bad_rows = 0
    example_file = None
    prg_interval = 200_000
    output_dir = config.output_dir
    path_output = make_output_dir(config=config)

    # 2. Count total rows (physical lines - header)
    logger.info("Detecting total number of rows...")
    rows_found = count_rows_in_file(csv_path)
    if rows_found <= 0:
        return Output(value="No data to process", metadata={"rows_found": 0})

    # 3. Process data with progress reporting
    logger.info(f"Starting processing of {rows_found:,} rows...")
    logger.info(f"Storing JSON files into: {output_dir}")

    with open(csv_path, "r", encoding="utf-8", errors="replace", newline="") as f:
        reader = csv.reader(f, delimiter="\t", quoting=csv.QUOTE_NONE)

        # Read header
        try:
            headers = next(reader)
            expected_cols = len(headers)
        except StopIteration:
            return Output(value="No data to process", metadata={"rows_found": 0})

        logger.info(f"Processed {0:5.1f}%  |  {0:,} rows")
        for i, row_list in enumerate(reader, 2):  # line numbers starting from 2 (after header)
            rows_processed += 1

            if len(row_list) != expected_cols:
                bad_rows += 1
                continue  # skip broken rows

            row = dict(zip(headers, row_list))
            prod_id = get_prod_id(row, i)

            # File name and path
            safe_id = "".join(c for c in prod_id if c.isalnum() or c in "-_.")
            file_path = path_output / f"icecat_{safe_id}.json"

            # Parse and store
            try:
                with open(file_path, "w", encoding="utf-8") as jf:
                    json.dump(row, jf, ensure_ascii=False, indent=2)
                files_count += 1
                if example_file is None:
                    example_file = str(file_path)

                # Progress reporting
                if rows_processed % prg_interval == 0 or rows_processed == rows_found:
                    percent = (rows_processed / rows_found) * 100
                    logger.info(f"Processed {percent:5.1f}%  |  {rows_processed:,} rows")

            except Exception as e:
                logger.warning(f"Row {i} ({safe_id}) failed: {e}")
                continue

    logger.info(f"Completed! Created {files_count:,} JSON files in {output_dir}")
    if bad_rows > 0:
        logger.info(f"Skipped {bad_rows:,} rows due to incorrect number of fields")

    return Output(
        value=f"Created {files_count:,} JSON files",
        metadata={
            "output_dir": output_dir,
            "rows_found": rows_found,
            "rows_processed": rows_processed,
            "rows_skipped": bad_rows,
            "files_generated": files_count,
            "example_file": example_file,
            "id_column": "product_id",
            "progress_interval": prg_interval,
        }
    )


@job(description="Parses IceCat CSV file into JSON files.")
def parse_icecat_csv_into_files():
    """Parses IceCat CSV file into JSON files."""
    logger = get_dagster_logger()

    # 1. Download CSV file
    logger.info("Starting IceCat CSV processing...")
    csv_path = icecat_csv()

    # 2. Parse CSV file
    logger.info(f"Processing file: {csv_path}")
    parse_csv_to_json(csv_path=csv_path)


__all__ = ["parse_icecat_csv_into_files"]
