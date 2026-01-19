# Misc Scripts

This folder contains miscellaneous development scripts, primarily used for building and running the solution locally. Do not use these script in production environments.
## Overview of Scripts

| Category           | Script                       | Description                                                  |
| ------------------ | ---------------------------- | ------------------------------------------------------------ |
| **Database**       |                              |                                                              |
|                    | `create.server.db.sh`        | Creates and starts a local database server instance          |
|                    | `sql/tpl.dagster.sql`        | Template SQL script for setting up the Dagster database schema and initial configuration. |
| **Dagster Images** |                              |                                                              |
|                    | `build.images.all.sh`        | Builds all required Dagster-related container images         |
| **Dagster Server** |                              |                                                              |
|                    | `create.server.dg.all.sh`    | Creates and starts all Dagster containers                    |
|                    | `create.server.dg.daemon.sh` | Helps to create and start the Dagster Daemon container       |
|                    | `create.server.dg.web.sh`    | Helps to create and start the Dagster Webserver container    |
|                    | `create.server.dg.pipes.sh`  | Helps to create and start a Dagster Pipes (user code) container |
| **Testing**        |                              |                                                              |
|                    | `build.and.run.sh`           | Tears down any previous local environment and creates a fresh one for testing |
| **Utilities**      |                              |                                                              |
|                    | `fn.podman.sh`               | Collection of helpful `podman` command shortcuts             |