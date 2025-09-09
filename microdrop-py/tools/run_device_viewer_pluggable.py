from logging import root
import os
import platform
import sys
import contextlib
import signal
import time
from pathlib import Path

# Set environment variables for Qt scaling for low DPI displays i.e, Raspberry Pi 4
if "pi" in platform.uname().node.lower():
        os.environ["QT_SCALE_FACTOR"] = "0.7"
        print(f"running with environment variables: {os.environ['QT_SCALE_FACTOR']}")

from envisage.ui.tasks.tasks_application import TasksApplication
from PySide6.QtWidgets import QApplication
from PySide6.QtGui import QFont

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from plugin_consts import (REQUIRED_PLUGINS, FRONTEND_PLUGINS, BACKEND_PLUGINS,
                                    FRONTEND_CONTEXT, BACKEND_CONTEXT, REQUIRED_CONTEXT,
                                    DEFAULT_APPLICATION)
from microdrop_utils._logger import get_logger
from microdrop_utils.font_helpers import load_font_family
from microdrop_utils.root_dir_utils import get_project_root

from microdrop_style.font_paths import load_material_symbols_font

root = get_project_root()

os.environ["PATH"] = str(root) + os.pathsep + os.environ.get("PATH", "") # Add root to PATH for PyInstaller. Should do nothing normal operation

# Font paths
INTER_FONT_PATH = root / "microdrop_style" / "fonts" / "Inter-VariableFont_opsz,wght.ttf"
LABEL_FONT_FAMILY = load_font_family(INTER_FONT_PATH) or "Inter"

# Load the Material Symbols font using the clean API
ICON_FONT_FAMILY = load_material_symbols_font() or "Material Symbols Outlined"

logger = get_logger(__name__)


def main(args, plugins=None, contexts=None, application=None, persist=False):
    """Run the application."""

    app_instance = QApplication.instance() or QApplication(sys.argv)
    app_instance.setFont(QFont(LABEL_FONT_FAMILY, 11))

    if plugins is None:
        plugins = REQUIRED_PLUGINS + FRONTEND_PLUGINS + BACKEND_PLUGINS
    if contexts is None:
        contexts = FRONTEND_CONTEXT + BACKEND_CONTEXT + REQUIRED_CONTEXT
    if application is None:
        application = DEFAULT_APPLICATION


    logger.debug(f"Instantiating application {application} with plugins {plugins}")

    # Instantiate plugins
    plugin_instances = [plugin() for plugin in plugins]

    # Instantiate application
    app = application(plugins=plugin_instances)

    def stop_app(signum, frame):
        print("Shutting down...")
        if isinstance(app, TasksApplication): # It's a UI application, so we call exit so that the application can save its state via TasksApplication.exit()
            app.exit()
        else: # It's a backend application, so we call Application.stop() since exit() doesn't exist
            app.stop()
        sys.exit(0)

    # Register signal handlers
    signal.signal(signal.SIGINT, stop_app)
    signal.signal(signal.SIGTERM, stop_app)

    with contextlib.ExitStack() as stack: # contextlib.ExitStack is a context manager that allows you to stack multiple context managers
        for context in contexts:
            stack.enter_context(context())
        app.run()
        if persist:
            while True:
                time.sleep(0.001)


if __name__ == "__main__":
    main(sys.argv)
