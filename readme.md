# Dagster Boilerplate / Launchpad

This solution serves as a "Foundation-as-Code," providing a standardized framework for building, testing, and deploying [Dagster](https://github.com/dagster-io/dagster)-based data pipelines throughout an organization at every stage. This approach ensures consistency, scalability, and efficiency while reducing errors and accelerating time-to-value for data-driven initiatives

🚀 We offer a single-line demo **installer**; see **[Quick Launch](#-quick-launch)**.

---

## 🤔 What Problem Does This Solve?

Standard Dagster documentation focuses on **concepts and code**, not **infrastructure and operations**. This leaves you asking:

- *"How do I run Dagster safely in production without Docker everywhere?"*
- *"Can I update my pipelines without restarting the dashboard?"*
- *"Why does a simple Dagster setup need so many moving parts?"*

**This boilerplate answers those questions.** It provides:

- **Separation of Concerns** – Three independent, loosely-coupled services (webserver, daemon, user code).
- **No Downtime Updates** – Change your pipelines without stopping Dagster.
- **Enterprise-Ready** – Works with Rootless Podman, Kubernetes, VMs, or bare metal.
- **Everything Included** – Pre-configured storage, resources, and monitoring.
- **Separated workflows** - Different teams can work on different parts simultaneously.
- **Versioning** - Simpler to manage **different versions** in development, staging, and production.
- **Segmentation** - Problems stay more contained with fewer surprises when something changes.
- **No limitations** - This solution imposes no restrictions, letting you build anything on top of it.

Unlike standard Dagster tutorials and how-to guides, this repository offers a ready-to-use, fully self-contained, enterprise-grade Data Platform tailored specifically for Cloud-Hybrid setups.

## 🍎 Why this Solution?

This solution offers a unified infrastructure layer for containerized environments with isolation, automated CI/CD guardrails (e.g., GitHub Actions), and pre-defined Dagster resources for quick startup—instead of specific data-moving scripts. The "foundation" approach lets developers plug data logic into a stable, production-ready system, separating platform from business logic to enforce consistent engineering standards across all tasks, regardless of author.

It acts as a **forkable boilerplate** for custom Dagster solutions **or** provides **ready-to-use pre-compiled container images**—pull to launch instantly and overlay custom code.

### 🎯 Core Use Cases

- **For Newcomers:** A **"Single-Click" learning environment.** Skip the 4-hour infrastructure setup and jump directly into the Dagster UI with a pre-configured, working asset graph.
- **For Pro Data Engineers:** A **zero-friction R&D playground.** Test complex dbt integrations, custom sensors, or new libraries in a local environment that perfectly mirrors production.
- **For Infrastructure Leads:** A **hardened self-hosting blueprint.** Designed for Bare Metal, VMs, or private Clouds using **Rootless Podman**, ensuring compliance in high-security environments where Docker is restricted.

### 🏗️ Lifecycle Support

This boilerplate is "Environment-Aware," providing a unified "Golden Path" from your laptop to the data center:

- **Development:** Local hot-reloading with mounted volumes.
- **Testing:** Integrated CI/CD pipelines for automated image builds.
- **Production:** Fully decoupled GRPc architecture ready for high-availability deployment.

### 💡 Why This Solution Stands Out

Unlike typical Dagster tutorials or boilerplates, this is **ready-to-use infrastructure code**, not just example scripts.

| What You Usually Get    | What You Get Here                                 |
| :---------------------- | :------------------------------------------------ |
| How-to guides           | Working, deployable system                        |
| DIY infrastructure      | Battle-tested architecture                        |
| All in one container    | Three focused, decoupled services                 |
| Update = restart system | Update pipelines, daemon, webserver independently |
| Boilerplate only        | Pre-built images (zero setup) + source code       |

## 🎯 Choose Your Path

### **Path A: The Launchpad - Pre-Built Images**

👉 **For most users** – fastest way to get started

- No building, no compiling
- Download & run pre-built Dagster containers from [quay.io](https://quay.io/repository/bpsbits/dagster?tab=tags)
- Perfect for learning, testing, and development
- Can be extended with custom code

[Read Launchpad documentation →](./docs/launchpad.md)

### **Path B: The Boilerplate - Build From Source**

👉 **For advanced use cases** – full control, customize everything

- Extend with private Python packages
- Add OS-level binaries (GPU drivers, database clients)
- Use your own hardened base images for compliance
- Full build pipeline included

[Read Boilerplate documentation →](./docs/boilerplate.md)

## 🔎 How It Works

Instead of one monolithic Dagster container, this solution separates concerns into **three independent, highly focused services**. Each can be updated, restarted, or scaled independently.

**We have not altered Dagster itself** — we are using the **official Dagster version unchanged**. We only packaged it into separate, easy-to-maintain Docker containers.

It enforces the "Separation of Concerns" that reduces infrastructure failures. It provides a blueprint that respects the lifecycle of data engineering, where deployments are frequent and infrastructure stability is non-negotiable.

### 🧩 The Three-Component Architecture

Instead of putting everything into one big, complicated monolith, we separated Dagster into three logical, independent parts. This structure makes it more flexible, faster to update, safer to manage across multiple environments (DevOps).

| Component       | Role                             | Description                                                  |
| :-------------- | :------------------------------- | :----------------------------------------------------------- |
| **`webserver`** | [**Dashboard**](./src/webserver) | The visual interface for launching runs, viewing assets, and monitoring logs. |
| **`daemon`**    | [**Worker**](./src/daemon)       | The background worker that automatically manages schedules, sensors, and queuing. |
| **`pipes`**     | [**User Code**](./src/pipes)     | Where your work lives. Houses your actual Python logic, dbt models, and data integrations. |

#### Why Separation Matters

- **Update Pipelines Without Downtime** – Deploy new code to `pipes` while users work in the dashboard  
- **Faster Iteration** – Change your Python logic, not your infrastructure  
- **Team Ownership** – Backend engineers maintain daemon/webserver; data engineers own pipes  
- **Easier Debugging** – Problems are isolated and easier to trace  
- **Production-Ready** – Mirrors how real enterprises run Dagster  

### 📁 Project Structure

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

### 📀 Building and using images (Dev Time)

This project's code is written with **Podman** in mind (*rootless*), but you can easily switch to **Docker** by making the necessary adjustments to the related configuration and commands. Based on our practical experience, Podman is generally easier to use and requires fewer system resources than Docker on both Linux and macOS.

---

## 📦 The Launchpad

You can use pre-built Dagster container images for any purpose, ranging from testing and learning to intensive development and production environments. These images are hosted on quay.io for near-instantaneous startup.

**Repository:** 

- [https://quay.io/repository/bpsbits/dagster?tab=tags](https://quay.io/repository/bpsbits/dagster?tab=tags&referrer=grok.com)

### Why use the Launchpad?

Use these pre-built images if you aim to minimize the overhead (tax) of learning, development, and deployment:

* **Bootstrap Speed:** Building Dagster images from scratch can take time because of heavy Python dependencies; these images reduce that time to seconds.
* **Compatibility:** They have already solved the "version hell" between the Dagster core version and library dependencies.
* **Zero-Config Security:** Often, these images come with pre-configured health checks and non-root users, which are security best practices that developers often skip when building their own.

[Read Boilerplate documentation →](./docs/boilerplate.md)

### 🚀 Quick Launch

Quick way to test the Launchpad right now:

```shell
curl -sSL https://raw.githubusercontent.com/bpsbits-org/dagster/main/_scripts/launchpad/run.sh | bash
```

**What it does:**

- Downloads & runs the installer → clones the repo → sets up the Dagster Launchpad demo.

**Needs:**

- `git` and `podman` (install via [Podman Desktop](https://podman-desktop.io/) if missing).

## 🛠 The Boilerplate

While pre-built images are highly useful, consider customizing or extending the boilerplate in these scenarios:

1. **Private Dependencies:** You need to install private Python packages from a secure registry.
2. **OS-level Binaries:** Your pipelines require specific Linux drivers (e.g., for GPU processing or specialized database drivers like Oracle/MS SQL).
3. **Strict Compliance:** Your organization requires all images to be scanned and built from a specific internal base image (like a hardened Alpine or RedHat UBI image).

[Read Boilerplate documentation →](./docs/boilerplate.md)

---

## 🚢 Shipping Pipes - Two Ways to Deploy Your Code

It's completely up to you how you deploy your user code; the best choice depends on your specific use case.

1. **As a container image**
   * Build and deploy a new container (`pipes`) image every time your code changes.
   * Generally **more secure** and better suited for certain production environments.
2. **Using a mounted volume**
   * Deploy the pipes container once and mount your code directory (from shared or cloud storage) as a volume.
   * Code updates are available without rebuilding the image, making it convenient for easy updates.

---

## 📚 Help / Documentation

See the [.docs](./docs/) folder for more information and guidelines.

✦ ✦ ✦
