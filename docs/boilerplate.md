## Boilerplate (Customization)

How to customize or extend the current project for custom builds.

**The Bottom Line:** Boilerplate mode is for those who want the power of a custom-built solution with the speed of a pre-made template. You get the best of both worlds: full control and a 5-minute head start.

### 🛠️ What is "Boilerplate Mode"?

While the **Launchpad** is like renting a fully furnished apartment where you just bring your clothes, **Boilerplate Mode** is like getting the architectural blueprints to build your own custom home. In this context, it means you aren't just using our pre-built images; you are cloning the entire repository to use as the foundation for your own unique data product.

It is the path for teams who want complete ownership. You take our "standardized factory" (the repo), rename it, and start building your own specialized images for your specific business needs.

### 🌟 Why Choose the Boilerplate Path?

Even though it requires more technical heavy lifting, this mode is designed to give you a massive head start without forcing you to "invent the entire wheel" from scratch.

* **Accelerated Adoption:** If you are introducing Dagster into your existing solution for the first time, you need to hit the ground running. This path provides a professional, "production-ready" scaffold immediately, allowing you to focus on your data logic rather than spending weeks architecting the underlying infrastructure.
* **Modernizing Your Workflow:** If you already have a Dagster setup but your current deployment feels manual, fragile, or hard to manage, moving to this boilerplate helps you "level up." It provides a standardized model that turns a collection of scripts into a professional, scalable data product.
* **Don't Reinvent the Plumbing:** The complex setup for how Dagster, the Daemon, and the Webserver talk to each other is already solved. You just focus on adding your logic into the `pipes/app` folder.
* **One Codebase, Everywhere:** One of the biggest wins is **standardization**. You use the exact same code structure on your local laptop for development, in your testing environments, and finally in your live production system.
* **Automated Publishing:** Once you add your code, you can set up automation to build and "ship" your images to your own private servers automatically.
* **Complete Customization:** Since you own the code, you can change the underlying Linux version, add specialized security layers, or bake in complex database drivers that aren't included in standard images.

### 🧱 What You’ll Need

Because you are "running the factory" yourself, this path is more complex and requires a bit more technical "muscle" than the Launchpad:

1. **DevOps Competence:** You’ll need someone who understands how Podman/Docker and automation (CI/CD) work.
2. **Private Infrastructure:** You will need your own private image repository (like GitHub Packages, AWS ECR, or GitLab Registry) to store your custom-built "sealed boxes".
3. **Maintenance:** Since you’ve cloned the code, you are now the captain of your own ship. You’ll be responsible for keeping your versions up to date and managing your own deployment servers.

### 🛣️ The Workflow: From Clone to Production

Getting started with the Boilerplate follows a simple, humane logic:

1. **Clone:** Take a copy of this repository and make it your own.
2. **Add Your Magic:** Put your Python data scripts and assets into the `pipes/app` directory.
3. **Automate:** Set up your "shipping line" (CI/CD) so that every time you save your work, a new, verified image is created.
4. **Deploy:** Run your custom images across your infrastructure with the peace of mind that they have been tested and standardized.

✦ ✦ ✦

Will be updated...