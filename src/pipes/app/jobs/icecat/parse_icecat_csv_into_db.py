# app/jobs/icecat/parse_icecat_csv_into_db.py
from typing import Optional

from dagster import job, get_dagster_logger, Output, op
from psycopg2.extras import Json
import csv
import json

from assets.icecat_csv import icecat_csv
from jobs.icecat.count_rows_in_file import count_rows_in_file
from resources.pg.PgStorageRs import PgStorageRs


class ICToDbMeta:
    """Metadata for the CSV file parsing job."""
    bad_rows: int = 0
    batch_size: int = 1000
    error: Optional[str] = None
    example: Optional[str] = None
    found: int = 0
    id_column: str = "product_id"
    inserted: int = 0
    prg_interval: int = 100_000
    processed: int = 0

    def to_meta(self):
        return {
            "rows_found": self.found,
            "rows_processed": self.processed,
            "rows_skipped": self.bad_rows,
            "rows_inserted": self.inserted,
            "data_example": self.example,
            "id_column": "product_id",
            "progress_interval": self.prg_interval,
        }

    @staticmethod
    def descriptions():
        return {
            "rows_found": "Total number of rows found in the CSV file",
            "rows_processed": "Total number of rows processed from the CSV file",
            "rows_skipped": "Number of rows skipped due to incorrect number of fields",
            "rows_inserted": "Number of rows inserted into the database",
            "data_example": "An example row from the CSV file",
            "id_column": "Name of the column used as product ID",
            "progress_interval": "Number of rows processed between progress reports",
            "error": "Error message if any"}


@op(description="Parses CSV file and stores data into a database.",
    required_resource_keys={"db_storage"},
    tags={"group": "icecat"})
def ic_meta_to_db(context, csv_path: str) -> Output:
    """Parses CSV file and stores into a database."""
    mt = ICToDbMeta()
    db: PgStorageRs = context.resources.db_storage

    # 2. Count total rows (physical lines - header)
    context.log.info("Detecting total number of rows...")
    mt.found = count_rows_in_file(csv_path)
    if mt.found <= 0:
        mt.error = "No rows to process"
        return Output(value="No data to process", metadata=mt.to_meta())

    # 3. Process data with progress reporting
    context.log.info(f"Starting processing of {mt.found:,} rows...")
    with open(csv_path, "r", encoding="utf-8", errors="replace", newline="") as f:
        reader = csv.reader(f, delimiter="\t", quoting=3)  # Value 3 is equal to csv.QUOTE_NONE

        # Read CSV header
        try:
            headers = next(reader)
            expected_cols = len(headers)
        except StopIteration:
            mt.error = "No header found in CSV file."
            return Output(value="Invalid header", metadata=mt.to_meta())

        try:
            with db.conf() as cn:
                with cn.cursor() as cur:
                    context.log.info(f"Processed {0:5.1f}%  |  {0:,} rows")
                    batch = []
                    for i, row_list in enumerate(reader, 2):  # line numbers starting from 2 (after header)
                        mt.processed += 1

                        if len(row_list) != expected_cols:
                            mt.bad_rows += 1
                            continue  # Skip bad rows

                        # Store product row
                        row: dict = dict(zip(headers, row_list))
                        prod_id: int = int(row.get("product_id", ""))
                        data: Json = Json(row)
                        batch.append((prod_id, data))

                        if mt.example is None:
                            mt.example = json.dumps(row, indent=4)

                        # Process queries batch if full or at the end
                        if len(batch) >= mt.batch_size or mt.processed == mt.found:
                            cur.executemany('select "saveIceCatProductMeta"(%s, %s)', batch)
                            cn.commit()
                            mt.inserted += len(batch)
                            batch = []

                        # Progress reporting
                        if mt.processed % mt.prg_interval == 0 or mt.processed == mt.found:
                            percent = (mt.processed / mt.found) * 100
                            context.log.info(f"Processed {percent:5.1f}%  |  {mt.processed:,} rows")

        except Exception as e:
            mt.error = f"{str(e)}"
            return Output(value="Failed to store data", metadata=mt.to_meta())

    return Output(
        value=f"Added/updated {mt.inserted:,} rows.",
        metadata=mt.to_meta(),
    )


@job(description="Parses IceCat CSV file and stores into a database.",
     tags={"group": "icecat"},
     metadata=ICToDbMeta.descriptions(), )
def parse_icecat_csv_into_db():
    """Parses IceCat CSV file and stores into a database."""
    logger = get_dagster_logger()

    # 1. Download CSV file
    logger.info("Starting IceCat CSV processing...")
    csv_path = icecat_csv()

    # 2. Parse CSV file
    logger.info(f"Processing file: {csv_path}")
    ic_meta_to_db(csv_path=csv_path)


__all__ = ["parse_icecat_csv_into_db"]
