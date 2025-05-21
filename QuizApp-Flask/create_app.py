from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from quiz_app.routes import main
from quiz_app.extentions import db  # db = SQLAlchemy() defined here

login_manager = LoginManager()

def create_app(config_file: str = "config.py") -> Flask:
    """
    Create flask instance, set configuration from config_file.

    Parameters:
        - config_file: str
    Returns:
        - app: Flask
    """
    app = Flask(__name__)
    app.config["UPLOAD_FOLDER"] = "upload_files"
    app.config.from_pyfile(config_file)

    # Initialize extensions with app
    db.init_app(app)
    login_manager.init_app(app)
    login_manager.login_view = "main.login"

    # Register blueprints
    app.register_blueprint(main)

    # Create tables
    with app.app_context():
        db.create_all()

    return app
