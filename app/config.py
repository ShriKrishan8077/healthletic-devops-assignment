import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


class Config:
    APP_NAME = os.getenv("APP_NAME", "Healthletic Flask API")
    APP_VERSION = os.getenv("APP_VERSION", "1.0.0")

    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = os.getenv("DB_PORT", "3306")
    DB_NAME = os.getenv("DB_NAME", "healthletic")
    DB_USER = os.getenv("DB_USER", "postgres")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")