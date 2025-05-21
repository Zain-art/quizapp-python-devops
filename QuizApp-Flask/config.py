# config.py
from os import environ

SECRET_KEY = environ.get("SECRET_KEY") or "github.com/Dev-Bittu"
SQLALCHEMY_DATABASE_URI = environ.get("SQLALCHEMY_DATABASE_URI") or "sqlite:////app/data/quizapp.db"
SQLALCHEMY_TRACK_MODIFICATIONS = False