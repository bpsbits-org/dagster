# Dagster - Pipes (User Code)

Pipes (in this setup) is the container that holds your own data pipeline code — the Python logic that actually fetches, processes, transforms, and saves data. It's kept separate so you can update your pipelines frequently and safely, without re-deploying webserver or daemon.

## Two ways to deploy your code:

1. **As a container image** - Build and deploy a new container image every time your code changes.
2. **Using a mounted volume** - Deploy the pipes container once, then **mount** your code directory (from a persistent volume, shared storage, or cloud file system) as a volume when creating/starting the container — code updates are immediately visible without rebuilding the image.