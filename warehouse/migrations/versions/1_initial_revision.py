"""Initial Revision

Revision ID: 1
Revises: None
Create Date: 2014-12-04 13:11:45.727956

"""

# revision identifiers, used by Alembic
revision = '1'
down_revision = None

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.mysql import VARBINARY, TIMESTAMP, TINYINT, INTEGER


def upgrade():
    ### commands  start###
    op.create_table(
        'edit',
        sa.Column('time', TIMESTAMP, nullable=False),
        sa.Column('wiki', VARBINARY(100), nullable=False),
        sa.Column('user_id', INTEGER(11), nullable=False),
        sa.Column('rev_id', INTEGER(11), nullable=False),
        sa.Column('page_id', INTEGER(11), nullable=False),
    )

    op.create_index('i1', 'edit', ['wiki', 'time'])

    op.create_index('i2', 'edit', ['time', 'wiki'])

    op.create_table(
        'page',
        sa.Column('wiki', VARBINARY(100), nullable=False),
        sa.Column('page_id', INTEGER(11), nullable=False),
        sa.Column('namespace', TINYINT, nullable=False),
        sa.Column('archived', TINYINT, nullable=False, server_default='0'),
        sa.Column('valid_to', TIMESTAMP, nullable=False),
        sa.Column('valid_from', TIMESTAMP, nullable=False),
        sa.Column('valid_currently', TINYINT, nullable=False,
                  server_default='0'),
    )

    op.create_index('i1', 'page', ['wiki', 'page_id'])

    op.create_index('i2', 'page', ['wiki', 'namespace', 'page_id'])

    op.create_table(
        'user',
        sa.Column('wiki', VARBINARY(100), nullable=False),
        sa.Column('user_id', INTEGER(11), nullable=False),
        sa.Column('user_name', VARBINARY(100), nullable=False),
        sa.Column('user_registration', TIMESTAMP,
                  nullable=False),
        sa.Column('in_bot_user_group', TINYINT, nullable=False,
                  server_default='0'),
        sa.Column('valid_to', TIMESTAMP,
                  nullable=False),
        sa.Column('valid_from', TIMESTAMP, nullable=False),
        sa.Column('valid_currently', TINYINT, nullable=False,
                  server_default='0'),

    )
    op.create_index('i1', 'user',
                    ['wiki', 'user_id',
                     'in_bot_user_group', 'user_registration'])

    op.create_index('i2', 'user', ['wiki', 'user_name'])

    op.create_index('i3', 'user', ['wiki', 'user_registration'])

    ### end Alembic commands ###


def downgrade():
    ### commands start ###
    op.drop_table('user')
    op.drop_table('edit')
    op.drop_table('page')
    op.drop_index('i1', table_name='edit')
    op.drop_index('i2', table_name='edit')
    op.drop_index('i1', table_name='page')
    op.drop_index('i2', table_name='page')
    op.drop_index('i1', table_name='user')
    op.drop_index('i2', table_name='user')
    op.drop_index('i3', table_name='user')
    ### end Alembic commands ###
