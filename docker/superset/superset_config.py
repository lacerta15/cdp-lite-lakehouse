"""CDP-Lite Superset config.

Reads SECRET_KEY from env so the image is portable.
Disables example data loading for a clean demo state.
"""
import os

SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "change-me")
SQLALCHEMY_DATABASE_URI = "sqlite:////app/superset_home/superset.db"

# Branding
APP_NAME = "CDP-Lite Lakehouse BI"
LOGO_TARGET_PATH = "/superset/welcome/"

# Disable telemetry for the demo
SCARF_ANALYTICS = False

# Sensible defaults for laptop
ROW_LIMIT = 10000
SUPERSET_WEBSERVER_TIMEOUT = 120

FEATURE_FLAGS = {
    "DASHBOARD_RBAC": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}
