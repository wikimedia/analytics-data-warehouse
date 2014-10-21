from __future__ import with_statement
from alembic import context
from sqlalchemy import create_engine
from logging.config import fileConfig

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers
fileConfig(config.config_file_name)

# other values from the config, defined by the needs of env.py,
# can be acquired:
# my_important_option = config.get_main_option('my_important_option')
# ... etc.


def get_engine():
    '''
    Create a sqlalchemy engine for a database.

    Returns:
        sqlalchemy engine connected to the database.
    '''

    return create_engine(
        'mysql://user:password@localhost/warehouse',
        echo=False,
        connect_args={'charset': 'utf8'}
    )


def run_migrations_offline():
    '''Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well. By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.

    '''
    url = get_engine().url
    context.configure(url=url)

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online():
    '''
    Not supported
    '''
    raise Exception('Online migrations are not supported')


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
