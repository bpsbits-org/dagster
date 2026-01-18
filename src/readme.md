# `src` - Source root

This folder contains the source code for building three separate **Docker images**.

The three main folders are:

- **[daemon](./daemon)** – Source code for the **Dagster Daemon** image. This is the background service that runs continuously. It automatically starts scheduled jobs on time, checks for data changes (via sensors), manages the job queue, and keeps everything running smoothly — even when no one is watching the dashboard.
- **[pipes](./pipes)** – Source code for the **User Code (Pipes)** image. This contains your actual pipelines — the Python code that defines what data to process, how to transform it, and where to store the results.    We run it separately (using Dagster's "Pipes" approach) so you can update your data logic frequently and safely, without disturbing the rest of the system.
- **[webserver](./webserver)** – Source code for the **Dagster Webserver** image. This powers the Dagster web interface (dashboard) you open in a browser.

By keeping user pipelines (**pipes**) in their own image/container, you can deploy changes to your data code often and independently — without downtime for the dashboard (**webserver**) or background worker (**daemon**). This makes development faster, safer, and more reliable.

For more details, please refer to the `README` files in each subcomponent folder.
