#!/bin/bash
set -e

pip install --upgrade -U --upgrade pip
pip install --upgrade --upgrade -r requirements.txt

exec "$@"
