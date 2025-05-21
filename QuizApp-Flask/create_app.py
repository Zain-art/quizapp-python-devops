from flask import Flask
from quiz_app.routes import main
from quiz_app.extentions import db
from flask_login import LoginManager

login_manager = LoginManager()

def create_app(config_file: str = "config.py") -> Flask:
    """
    Create flask app instance and initialize extensions.

    Parameters:
    - config_file (str): Path to configuration file.

    Returns:
    - app (Flask): The created Flask application instance.
    """
    app = Flask(__name__)

    # Set upload folder path
    app.config["UPLOAD_FOLDER"] = "upload_files"

    # Load config from the given file
    app.config.from_pyfile(config_file)

    # Register blueprints
    app.register_blueprint(main)

    # Initialize database with app
    db.init_app(app)

    # Initialize login manager
    login_manager.init_app(app)
    login_manager.login_view = "main.login"

    # Create database tables within app context
    with app.app_context():
        db.create_all()

    return app
