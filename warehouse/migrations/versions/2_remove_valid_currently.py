"""Initial Revision

Revision ID: 2
Revises: None
Create Date: 2014-12-04 13:11:45.727956

"""

# revision identifiers, used by Alembic
revision = '2'
down_revision = '1'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.mysql import TINYINT


def upgrade():
    ### commands  start###
    op.drop_column('page', 'valid_currently')
    op.drop_column('user', 'valid_currently')


    ### end Alembic commands ###


def downgrade():
    ### commands start ###
    op.add_column('page', sa.Column('valid_currently', TINYINT, nullable=False,
                  server_default='0'))
    op.add_column('user', sa.Column('valid_currently', TINYINT, nullable=False,
                  server_default='0'))
    ### end Alembic commands ###
