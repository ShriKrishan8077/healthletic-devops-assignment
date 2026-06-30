import mysql.connector
from app.config import Config


def get_db_connection():
    """
    Create and return a MySQL database connection.
    """

    connection = mysql.connector.connect(
        host=Config.DB_HOST,
        port=int(Config.DB_PORT),
        database=Config.DB_NAME,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD
    )

    return connection