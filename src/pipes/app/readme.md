# User Code

To keep maintenance simple and organized, your user code (the code inside the pipes container) is neatly divided into the following dedicated directories:

- `assets` – definitions of data assets (what data gets produced);
- `jobs` – pipeline/job definitions (the main workflows);
- `resources` – definitions of reusable connections, clients, and configurations;
- `schedules` – definitions of when jobs should run automatically;
- `sensors` – definitions of event-based triggers.

This clear separation makes it much easier to find, update, and understand your code — even as the project grows.