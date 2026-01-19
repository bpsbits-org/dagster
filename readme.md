# Dagster Boilerplate / Launchpad

This project contains the source code for three main **container images** that work together to run **[Dagster](https://github.com/dagster-io/dagster)** — a popular tool that helps teams build, run, schedule, and monitor data pipelines (think of it as a very smart task manager for data work).

You can use this project as a **boilerplate** for building your own Dagster-based solution,  **or you can simply use the pre-built (already compiled) container images** (based on this project) to run Dagster quickly and extend it with your own custom functionality.

This project's code is built with **Podman** in mind,  but you can easily switch to **Docker** by making the necessary adjustments to the related configuration and commands. However, based on our practical experience, Podman is generally easier to use and requires fewer system resources than Docker on both Linux and macOS.

## About the Solution

**We have not altered Dagster itself** — we are using the **official Dagster version unchanged**. We only packaged it into separate, easy-to-maintain Docker containers.

We made the deployment simpler, safer, and more flexible by dividing Dagster into three logical, independent containers instead of one big monolith.We have split it into three separate  container images:

- `daemon`,
- `pipes`,
- `webserver`.

This type of structure has proven very practical in real projects — both for small teams and larger organisations.

## Pre-built Dagster container images

You can use pre-built Dagster container images for any purpose, ranging from testing and learning to intensive development and production environments.

For available images, please refer to the repository:

- [https://quay.io/repository/bpsbits/dagster?tab=tags](https://quay.io/repository/bpsbits/dagster?tab=tags&referrer=grok.com)

Available images:

- `daemon`
- `webserver`
- `pipes`

## Why did we do this?

Instead of putting everything into one big, complicated container, we separated the different responsibilities of Dagster into **three clear parts**. This three-image architecture makes Dagster more flexible, faster to update, safer to operate, and much easier to manage — especially in real-world projects that run for months or years across multiple environments (DevOps).

Think of it like organising a small team instead of asking one person to do everything:

- **webserver** → the nice dashboard everyone looks at in the browser;
- **daemon** → the quiet background worker that automatically runs scheduled tasks;
- **pipes** → your actual data pipelines (the real work you care about most).

### What are the benefits of this separation?

- Much easier to **update** only the part you changed (especially your own data pipelines in **pipes**) without touching the rest.
- You can **upgrade** or **restart** one piece without stopping the whole system.
- Different teams can work on different parts at the same time (data engineers on pipes, platform team on daemon/webserver).
- Much simpler to manage **different versions** in development, staging, and production.
- Fewer surprises when something changes — problems stay more contained.

## When to use Launchpad

This [repository](https://quay.io/repository/bpsbits/dagster?tab=tags&referrer=grok.com) provides pre-built images (hosted on quay.io) for near-instantaneous startup. Use these if you aim to minimize the overhead (tax) of learning, development, and deployment.

- **Bootstrap Speed:** Building Dagster images from scratch can take time and effort because of heavy Python dependencies (Pandas, SQLAlchemy, etc.). Using their pre-built images reduces this to seconds.
- **Compatibility:** They have already solved the "version hell" between the Dagster core version and the library dependencies
- **Zero-Config Security:** Often, these images come with pre-configured health checks and non-root users, which are security best practices that developers often skip when building their own.

## When to use Boilerplate?

While pre-built images are highly useful, consider customizing or extending the boilerplate in these scenarios:

1. **Private Dependencies:** You need to install private Python packages from a secure registry.
2. **OS-level Binaries:** Your pipelines require specific Linux drivers (e.g., for GPU processing or specialized database drivers like Oracle/MS SQL).
3. **Strict Compliance:** Your organization requires all images to be scanned and built from a specific internal base image (like a hardened Alpine or RedHat UBI image).

## Two ways to deploy your code:

1. **As a container image** - Build and deploy a new container (`pipes`) image every time your code changes.
2. **Using a mounted volume** - Deploy the pipes container once and mount your code directory (from a persistent volume, shared storage, or cloud file system) as a volume when creating/starting the container — code updates are available without rebuilding the image.

It's completely up to you how you deploy your user code. There is no single "perfect" option — the best choice depends on your specific use case.

- The **container image** approach is generally **more secure** and better suited for certain production environments.
- The **volume-mounted** approach can be more convenient when you want to install your container-based solution once and then update the code easily without frequently rebuilding and redeploying the image.

Choose whichever fits your workflow and security needs best.

## Help / Documentation

See the [.docs](./docs/) folder for more information and guidelines.



✦ ✦ ✦
