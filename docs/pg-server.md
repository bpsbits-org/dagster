#  Database for Dagster

How to set up a PostgreSQL server, database, schema, and configuration for Dagster.

This solution uses a PostgreSQL database for Dagster to store operational data, such as run instructions, event logs, and schedules. While Dagster supports other storage options, the **current solution relies on PostgreSQL** for persistence and management of workflows.

The current solution requires:

- A **PostgreSQL server** (only PostgreSQL is supported in this implementation).
- A **dedicated user** for Dagster.
- Access to a **database** with a **dedicated schema** for Dagster.

## PostgreSQL Server

We provide sample code to quickly set up a PostgreSQL server for local development environments. However, we do not include instructions for staging or production environments, as there are many possible configurations (e.g., cloud-hosted services like AWS RDS or self-managed servers).

The following environment variables are defined to operate and must be configured with appropriate values when running your live container (e.g., via `-e` flags in `podman create` or in your orchestration setup). These specify the **host and port and database for connecting to the PostgreSQL** server. Adjust them based on your environment, such as using a remote host for production.

```dockerfile
# DB Server and Database
ENV DGS_PG_SRV=host.containers.internal
ENV DGS_PG_PRT=5432
ENV DGS_PG_DBN=dagster
```

### Setting Up the Server & Database for Development

We provide an [automation script](../_scripts/create.server.db.sh) (located at `_scripts/create.server.db.sh)` to create and configure a PostgreSQL database in **development environments**. For development, we use Podman as the container orchestration platform, but you can easily adapt the script for use with Docker if preferred.

To create and run the database server, follow these steps:

1. Open a terminal and navigate to the project directory.
2. Execute the following command:

```shell
bash ./_scripts/create.server.db.sh
```

This script will handle the setup, including pulling the necessary PostgreSQL image, creating the container, and initializing the database.

If you already have PostgreSQL server, please refer to the [SQL script](../_scripts/sql/run.dagster.sql) (`run.dagster.sql`) for more details on how to prepare it for Dagster.

## Dedicated Database User

It is highly recommended to create a **dedicated database user exclusively for Dagster**, not shared with other applications or purposes. For any data transfer operations involving business data, use a separate user to prevent potential security risks. This isolation helps protect sensitive resources and maintains clear boundaries.

The following environment variables are defined to operate and must be configured with secure credentials when running your live container (e.g., via `-e` flags in `podman create` or in your orchestration setup). Ensure the user has appropriate permissions limited to the Dagster schema.

```dockerfile
# DB User
ENV DGS_PG_USR=
ENV DGS_PG_PSW=
```

## Dedicated Schema

Use a **dedicated schema** for Dagster to keep its data separate from other database content, avoiding conflicts with existing or future data. This encapsulation promotes organization and security by isolating Dagster's operational data from business logic.

The following environment variable is defined to operate and must be configured when running your live container (e.g., via `-e` flags in `podman create` or in your orchestration setup). You can change the schema name if needed, but "dagster" is the default for simplicity.

```dockerfile
# DB Schema
ENV DGS_PG_SCH=dagster
```

## Pre-Defined Access to Data Sources

We provide Dagster resources (in Python code) for connecting to a **single default data storage** and for **dynamic connections** to other PostgreSQL sources. These resources simplify data handling in your pipelines.

### Pre-Defined Storage Access

This resource is ideal for scenarios with a **single, persistent data storage** (e.g., a main database). Configure it once, and it can be reused across multiple operations, reducing setup overhead.

### Pre-Defined Dynamic Database Access

This resource supports connections to **multiple data storages**, making it useful when working with various sources. You'll need to configure it for each specific operation, allowing flexibility for complex workflows involving data from different locations.

## Pre-Defined User Configurations

We provide **pre-defined user configuration storage and access** resources, enabling you to easily store and reuse them for any of your Dagster operations. These pre-defined Dagster resources are available for storing and using such configurations. 

Please note that the data is stored in the database in `JSONB` format and is not encrypted, so this may not be the best option for highly sensitive information. However, this approach helps you avoid hard-coding configurations into your code; instead, you can define them separately for each instance, which prevents any leakage of configurations via code.

✦ ✦ ✦

Will be updated...
