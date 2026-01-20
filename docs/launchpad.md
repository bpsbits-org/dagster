# 🚀 Launchpad

How to use pre-built Dagster container images.

## 📦 Pre-built Dagster Images (Launchpad)

You can use pre-built Dagster container images for any purpose, ranging from testing and learning to intensive development and production environments. These images are hosted on quay.io for near-instantaneous startup.

**Repository Link:** [https://quay.io/repository/bpsbits/dagster?tab=tags](https://quay.io/repository/bpsbits/dagster?tab=tags&referrer=grok.com)

**Available images:**

* `daemon` - Background runner that handles scheduling, triggering, queuing, and monitoring data jobs automatically.
* `webserver` - Web dashboard for viewing, controlling, and interacting with those jobs via a browser.
* `pipes` - Keeps your custom code you write to define your data workflows, including the steps (ops), data assets, and jobs that process and transform data in Dagster. It's like the warehouse of blueprints for your automated data tasks.

### Why use the Launchpad?

Use these pre-built images if you aim to minimize the overhead (tax) of learning, development, and deployment:

* **Bootstrap Speed:** Building Dagster images from scratch can take time because of heavy Python dependencies; these images reduce that time to seconds.
* **Compatibility:** They have already solved the "version hell" between the Dagster core version and library dependencies.
* **Zero-Config Security:** Often, these images come with pre-configured health checks and non-root users, which are security best practices that developers often skip when building their own.

## 🚢 Two Ways to Deploy Your Code

Once you have the Dagster "brain" (the Daemon and Webserver) running, you need to provide your custom code—the actual instructions for your data tasks. There are two primary ways to get your code into the `pipes` container. 

Think of it like deciding whether to use a **Shared Bookshelf** (where anyone can swap a book at any time) or a **Pre-packed Kit** (where the contents are sealed at the factory).

### Option 1: The "Shared Folder" Approach (Mounted Volume)

In this setup, you point the Dagster container to a folder on your server or computer. The container "reads" your code directly from that folder. If you change a file in that folder, Dagster sees the update almost instantly.

**Best for:** Teams that want to keep things simple and avoid complex "Build" steps.

* Environments without a private Image Registry (like a local server or a single VM).
* Scenarios where you need to apply a quick fix to a production script without waiting for a full deployment pipeline.

| **Pros (The Good Stuff)**                                    | **Cons (The Trade-offs)**                                    |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Simple Maintenance:** No need to manage a Docker Registry or learn CI/CD pipelines. | **Manual Versioning:** It’s up to you to keep track of what changed and when (usually via Git). |
| **Instant Hot-fixes:** You can edit a file and save it; the "live" system updates without a restart. | **Scaling Pains:** If you run Dagster on multiple servers, you have to sync that folder across all of them (e.g., using NFS or GlusterFS). |
| **Lower Overhead:** Uses less disk space and network bandwidth since you aren't "shipping" heavy container images. | **Dependency Drift:** If your code needs a new Python library, you have to ensure it's manually available in the environment. |

### Option 2: The "Sealed Package" Approach (Custom Container Image)

Here, you take the pre-built `pipes` image and "bake" your code directly inside it. This creates a single, unchangeable file (the image) that contains your code, your libraries, and your settings. To update your code, you build a new version of the image.

**Best for:**

* Highly regulated environments where you need to "freeze" the code for security audits.
* Cloud-native setups (Kubernetes, AWS ECS, etc.) where "folders" don't naturally persist.
* Teams that want to guarantee that "what worked on my laptop" is exactly what is running in the cloud.

| **Pros (The Good Stuff)**                                    | **Cons (The Trade-offs)**                                    |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| **Rock-Solid Stability:** The code is "frozen." It cannot be accidentally changed by someone editing a file on the server. | **The "Wait" Factor:** Even a one-line typo fix requires a full "Build and Push" cycle, which can take minutes. |
| **Self-Contained:** Everything the code needs (drivers, libraries, tools) is inside the box. No external setup required. | **Infrastructure Heavy:** Requires an Image Registry (like Docker Hub, Quay, or AWS ECR) and usually an automated build system. |
| **Perfect Rollbacks:** If a new update fails, you just tell the system to run the previous version's image. | **Storage Cost:** Storing many versions of heavy images can eventually lead to higher storage costs and cleanup tasks. |

### Which one should you choose?

Neither method is "better" than the other; it depends entirely on how your organization operates.

* **Choose the Shared Folder (Volume) if:** You value **simplicity and speed**. If you are running on a single server or a local environment and you want to be able to fix a bug in seconds by just updating a file, this is for you. It's a great choice for teams that don't want the "extra work" of a full DevOps pipeline.
* **Choose the Sealed Package (Image) if:** You value **consistency and scale**. If you are deploying to a cluster of servers (like Kubernetes) or if you need a strict audit trail of exactly which version of the code was running last Tuesday, the Image approach is the industry standard.

**Tip:** You don't have to pick one forever. You could start with a **Shared Folder** to get your work done quickly and only switch to **Sealed Packages** if you find that "manual updates" are becoming too messy or risky as the team grows.

✦ ✦ ✦

Will be updated...
