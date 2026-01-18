from contextlib import contextmanager

from box import Box
from psycopg2.extras import Json

from resources.pg.DagsterDb import DagsterDb


class UserConf:
    """
    Simple persistent key-value configuration storage using Box (dot-notation-friendly).
    """

    @staticmethod
    @contextmanager
    def _get_connection():
        with DagsterDb.conn() as conn:
            yield conn

    @staticmethod
    def save(name: str, value) -> None:
        """
        Save configuration value (dict, Box, or any json-serializable structure)

        Args:
            name: Configuration key/name
            value: Value to store (will be converted to Box internally if needed)
        """
        # Convert to Box for consistency (handles nested structures nicely)
        if not isinstance(value, Box):
            value = Box(value)
        with UserConf._get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("select set_user_conf(%s, %s)", (name, Json(value)))

    @staticmethod
    def load(name: str) -> Box:
        """
        Load configuration by name

        Returns:
            Box object with dot-notation access

        Raises:
            ValueError: if configuration doesn't exist or is null
        """
        with UserConf._get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("select get_user_conf(%s)", (name,))
                row = cur.fetchone()
                if row is None or row[0] is None:
                    raise ValueError(f"Configuration '{name}' not found")
                return Box(row[0])
