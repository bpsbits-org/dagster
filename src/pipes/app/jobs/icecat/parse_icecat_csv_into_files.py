# app/jobs/icecat/parse_icecat_csv_into_files.py
import shutil
from typing import Optional

from dagster import job, op, get_dagster_logger, Output, Config
from pydantic import Field
from pathlib import Path
import csv
import json

from assets.icecat_csv import icecat_csv
from jobs.icecat.count_rows_in_file import count_rows_in_file
from jobs.icecat.get_prod_id import get_prod_id


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


class ICToFilesMeta:
    """Metadata for the CSV file parsing job."""
    output_dir: Optional[str] = None
    rows_found: int = 0
    rows_processed: int = 0
    bad_rows: int = 0
    files_count: int = 0
    example_file: Optional[str] = "None"
    id_column: str = "product_id"
    prg_interval: int = 200_000

    def to_meta(self):
        return Output(
            value=f"Created {self.files_count:,} JSON files",
            metadata={
                "output_dir": self.output_dir,
                "rows_found": self.rows_found,
                "rows_processed": self.rows_processed,
                "rows_skipped": self.bad_rows,
                "files_generated": self.files_count,
                "example_file": self.example_file,
                "id_column": self.id_column,
                "progress_interval": self.prg_interval,
            }
        )

    @staticmethod
    def descriptions():
        return {
            "output_dir": "Directory where JSON files will be written",
            "rows_found": "Total number of rows found in the CSV file",
            "rows_processed": "Total number of rows processed from the CSV file",
            "rows_skipped": "Number of rows skipped due to incorrect number of fields",
            "files_generated": "Number of JSON files generated",
            "example_file": "Path to an example JSON file generated",
            "id_column": "Name of the column used as product ID",
            "progress_interval": "Number of rows processed between progress reports",
        }


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
def parse_csv_to_json(config: ParserConf, csv_path: str) -> Output:
    """
    Parses large IceCat CSV → one JSON per product.
    Two-pass version: first counts total rows, then processes with percentage progress.
    Uses csv.reader to avoid silent row dropping on bad quoting.
    """
    logger = get_dagster_logger()
    mt = ICToFilesMeta()
    mt.output_dir = config.output_dir
    path_output = make_output_dir(config=config)

    # 2. Count total rows (physical lines - header)
    logger.info("Detecting total number of rows...")
    rows_found = count_rows_in_file(csv_path)
    if rows_found <= 0:
        return Output(value="No data to process", metadata={"rows_found": 0})

    # 3. Process data with progress reporting
    logger.info(f"Starting processing of {rows_found:,} rows...")
    logger.info(f"Storing JSON files into: {mt.output_dir}")

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
            mt.rows_processed += 1

            if len(row_list) != expected_cols:
                mt.bad_rows += 1
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
                mt.files_count += 1
                if mt.example_file is None:
                    mt.example_file = str(file_path)

                # Progress reporting
                if mt.rows_processed % mt.prg_interval == 0 or mt.rows_processed == rows_found:
                    percent = (mt.rows_processed / rows_found) * 100
                    logger.info(f"Processed {percent:5.1f}%  |  {mt.rows_processed:,} rows")

            except Exception as e:
                logger.warning(f"Row {i} ({safe_id}) failed: {e}")
                continue

    logger.info(f"Completed! Created {mt.files_count:,} JSON files in {mt.output_dir}")
    if mt.bad_rows > 0:
        logger.info(f"Skipped {mt.bad_rows:,} rows due to incorrect number of fields")

    return mt.to_meta()


@job(description="Parses IceCat CSV file into JSON files.",
     tags={"group": "icecat"},
     metadata=ICToFilesMeta.descriptions(),
     )
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
