# Dagster Boilerplate / Launchpad

This repository serves as a "Foundation-as-Code" project, providing a standardized framework for building, testing, and deploying [Dagster](https://github.com/dagster-io/dagster)) based data pipelines across an organization at every stage—from development to production. This approach ensures consistency, scalability, and efficiency, reducing errors and accelerating time-to-value for data-driven initiatives.

## 🚀 Sneak Peek & Key Value
This project contains the source code for three main **container images** that work together to run **[Dagster](https://github.com/dagster-io/dagster)** — a popular tool that helps teams build, run, schedule, and monitor data pipelines (think of it as a very smart task manager for data work).

You can use this project as a **boilerplate** for building your own Dagster-based solution, **or you can simply use the pre-built (already compiled) container images** (based on this project) to run Dagster quickly and extend it with your own custom functionality.

This project's code is built with **Podman** in mind, but you can easily switch to **Docker** by making the necessary adjustments to the related configuration and commands. Based on our practical experience, Podman is generally easier to use and requires fewer system resources than Docker on both Linux and macOS.

Instead of containing specific scripts for moving data, it provides a unified infrastructure layer for containerized environments—for isolation, automated CI/CD "guardrails" (GitHub Actions, etc.), and pre-defined Dagster Resources for quick startup.

This "foundation" approach allows developers to "plug in" their specific data logic into a stable, production-ready system. By separating the technical platform from the business logic, the repository ensures that all data tasks follow the same elite engineering standards regardless of who writes them.

## 📦 Pre-built Dagster Images (Launchpad)

You can use pre-built Dagster container images for any purpose, ranging from testing and learning to intensive development and production environments. These images are hosted on quay.io for near-instantaneous startup.

**Repository Link:** [https://quay.io/repository/bpsbits/dagster?tab=tags](https://quay.io/repository/bpsbits/dagster?tab=tags&referrer=grok.com)

**Available images:**
* `daemon`
* `webserver`
* `pipes`

### 🚀 Why use the Launchpad?

Use these pre-built images if you aim to minimize the overhead (tax) of learning, development, and deployment:
* **Bootstrap Speed:** Building Dagster images from scratch can take time because of heavy Python dependencies; these images reduce that time to seconds.
* **Compatibility:** They have already solved the "version hell" between the Dagster core version and library dependencies.
* **Zero-Config Security:** Often, these images come with pre-configured health checks and non-root users, which are security best practices that developers often skip when building their own.

Read more: [Launchpad documentation](./docs/launchpad.md).

## 🏗 About the Solution
**We have not altered Dagster itself** — we are using the **official Dagster version unchanged**. We only packaged it into separate, easy-to-maintain Docker containers.

Instead of putting everything into one big, complicated monolith, we separated Dagster into three logical, independent parts. This structure makes it more flexible, faster to update, safer to manage across multiple environments (DevOps).

Think of it like organizing a small team instead of asking one person to do everything:
* **[webserver](./src/webserver)** → the nice Dagster dashboard everyone looks at in the browser.
* **[daemon](src/daemon)** → the quiet Dagster background worker that automatically runs scheduled tasks.
* **[pipes](./src/pipes)** → your actual Dagster data pipelines (the real work you care about most).

### 🍎 Core Benefits

* Much easier to **update** only the part you changed (especially your data pipelines in **pipes**).
* You can **upgrade** or **restart** one piece without stopping the whole system.
* Different teams can work on different parts simultaneously.
* Simpler to manage **different versions** in development, staging, and production.
* Problems stay more contained with fewer surprises when something changes.

### 📂 Project Structure

This repository uses a clean, purpose-driven layout designed to keep your infrastructure, documentation, and automation separated and organized.

```
.
├── src/                    # The heart of the project: all main source code
│   ├── daemon/             # Logic and config for the background worker
│   ├── pipes/              # Your actual data pipelines (User Code)
│   └── webserver/          # Logic and UI settings for the Dagster dashboard
├── docs/                   # Extended guides, diagrams, and references
└── _scripts/               # Automation, build, and deployment utility tools
```

## 🛠 Customization (Boilerplate)

While pre-built images are highly useful, consider customizing or extending the boilerplate in these scenarios:
1. **Private Dependencies:** You need to install private Python packages from a secure registry.
2. **OS-level Binaries:** Your pipelines require specific Linux drivers (e.g., for GPU processing or specialized database drivers like Oracle/MS SQL).
3. **Strict Compliance:** Your organization requires all images to be scanned and built from a specific internal base image (like a hardened Alpine or RedHat UBI image).

Read more: [Boilerplate documentation](docs/boilerplate.md).

## 🚢 Two Ways to Deploy Your Code
It's completely up to you how you deploy your user code; the best choice depends on your specific use case.

1. **As a container image**
    * Build and deploy a new container (`pipes`) image every time your code changes.
    * Generally **more secure** and better suited for certain production environments.
2. **Using a mounted volume**
    * Deploy the pipes container once and mount your code directory (from shared or cloud storage) as a volume.
    * Code updates are available without rebuilding the image, making it convenient for easy updates.

## 📚 Help / Documentation
See the [.docs](./docs/) folder for more information and guidelines.

✦ ✦ ✦
