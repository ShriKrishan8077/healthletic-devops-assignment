import psycopg2
from app.config import Config


def get_db_connection():
    """
    Create and return a PostgreSQL database connection.
    """

    connection = psycopg2.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        database=Config.DB_NAME,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD
    )

    return connection