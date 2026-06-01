import tomllib
from sqlalchemy import create_engine, Engine
from urllib.parse import quote


def get_db(database: str | None = None) -> Engine:
    """
    Builds the database engine from the config.toml file in your working dir

    :param database: The name of the database you want to connect to, or
    else it reads the config. It reads the config anyway for user, host, pw
    """
    with open("config.toml", "rb") as f:
        config = tomllib.load(f)

    user = config["db"]["user"]
    pw = config["db"]["password"]
    # Optionally set database name, otherwise pull from the config file
    db = database if database else config["db"]["database"]
    host = config["db"]["host"]
    port = 5432

    return create_engine(
        f"postgresql+psycopg://{user}:{quote(pw)}@{host}:{port}/{db}"
    )
