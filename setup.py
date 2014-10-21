#!/usr/bin/env python
"""
Loads dependencies from requirements.txt and specifies installation details
"""
# follow the frog

from setuptools import setup
from pip.req import parse_requirements

# parse_requirements() returns generator of pip.req.InstallRequirement objects
INSTALL_REQS = parse_requirements('requirements.txt')

# REQS is a list of requirement
# e.g. ['flask==0.9', 'sqlalchemye==0.8.1']
REQS = [str(ir.req) for ir in INSTALL_REQS]

setup(
    name='warehouse',
    version='0.0.1',
    description='Python helpers for Warehouse (migrations, tests, etc.)',
    url='http://blah',
    author='Dan Andreescu, Nuria Ruiz',
    packages=[
        'warehouse',
    ],
    install_requires=REQS,
    entry_points={
    },
)
