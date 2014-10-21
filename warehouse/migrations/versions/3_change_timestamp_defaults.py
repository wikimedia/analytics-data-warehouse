"""Initial Revision

Revision ID: 3
Revises: None
Create Date: 2014-12-04 13:11:45.727956

"""

# revision identifiers, used by Alembic
revision = '3'
down_revision = '2'

from alembic import op
from sqlalchemy.dialects.mysql import TIMESTAMP


def upgrade():
    ### commands  start###
    # See notes about timestamp defaults for MySQL
    # defaulst are not intutive

    # http://docs.sqlalchemy.org/en/rel_0_9/dialects/mysql.html
    op.alter_column('page', 'valid_to', type_=TIMESTAMP,
                    nullable=True, existing_type=TIMESTAMP,
                    existing_nullable=False)
    op.alter_column('page', 'valid_from', type_=TIMESTAMP,
                    nullable=True, existing_type=TIMESTAMP,
                    existing_nullable=False)

    op.alter_column('user', 'valid_to', type_=TIMESTAMP,
                    nullable=True, existing_type=TIMESTAMP,
                    existing_nullable=False)
    op.alter_column('user', 'valid_from', type_=TIMESTAMP,
                    nullable=True, existing_type=TIMESTAMP,
                    existing_nullable=False)

    ### end Alembic commands ###


def downgrade():
    ### commands start ###
    op.alter_column('page', 'valid_to', type_=TIMESTAMP,
                    nullable=False, existing_type=TIMESTAMP,
                    existing_nullable=True)
    op.alter_column('page', 'valid_from', type_=TIMESTAMP,
                    nullable=False, existing_type=TIMESTAMP,
                    existing_nullable=True)

    op.alter_column('user', 'valid_to', type_=TIMESTAMP,
                    nullable=False, existing_type=TIMESTAMP,
                    existing_nullable=True)
    op.alter_column('user', 'valid_from', type_=TIMESTAMP,
                    nullable=False, existing_type=TIMESTAMP,
                    existing_nullable=True)

### end Alembic commands ###
