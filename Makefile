SHELL=/usr/bin/env bash

# Virtual environment directory
VENV_DIR = .venv
PYTHON_VERSION = 3.11

# Default goal
.DEFAULT_GOAL := help

# 🛠️ Create virtual environment with uv
.PHONY: create
create:
	@echo "Creating virtual environment with uv..."
	uv venv --python $(PYTHON_VERSION)
	@echo "Virtual environment created at $(VENV_DIR)"
	@echo "To activate: source $(VENV_DIR)/bin/activate"

# 🛠️ Install dependencies using uv sync
.PHONY: install
install:
	@echo "Installing dependencies with uv sync..."
	uv sync --dev

	@echo "Installing playwright browser..."
	uv run playwright install chromium --with-deps --no-shell

	@echo "Installation complete! Activate with: source $(VENV_DIR)/bin/activate"

# 🛠️ Install dependencies using requirements.txt
.PHONY: install-requirements
install-requirements:
	@echo "Installing dependencies from requirements.txt..."
	uv pip sync requirements.txt

	@echo "Installing playwright browser..."
	uv run playwright install chromium --with-deps --no-shell

	@echo "Installation complete! Activate with: source $(VENV_DIR)/bin/activate"

# 🛠️ Add a new dependency
.PHONY: add
add:
	@if [ -z "$(PKG)" ]; then \
		echo "Usage: make add PKG=package_name"; \
		exit 1; \
	fi
	@echo "Adding $(PKG) to project..."
	uv add $(PKG)

# 🛠️ Add a new dev dependency
.PHONY: add-dev
add-dev:
	@if [ -z "$(PKG)" ]; then \
		echo "Usage: make add-dev PKG=package_name"; \
		exit 1; \
	fi
	@echo "Adding $(PKG) as dev dependency..."
	uv add --dev $(PKG)

# 🛠️ Remove a dependency
.PHONY: remove
remove:
	@if [ -z "$(PKG)" ]; then \
		echo "Usage: make remove PKG=package_name"; \
		exit 1; \
	fi
	@echo "Removing $(PKG) from project..."
	uv remove $(PKG)

# 🛠️ Update all dependencies
.PHONY: update
update:
	@echo "Updating all dependencies..."
	uv sync --upgrade

# 🛠️ Update specific dependency
.PHONY: update-pkg
update-pkg:
	@if [ -z "$(PKG)" ]; then \
		echo "Usage: make update-pkg PKG=package_name"; \
		exit 1; \
	fi
	@echo "Updating $(PKG)..."
	uv sync --upgrade-package $(PKG)

# 🛠️ Sync dependencies (install missing, remove unused)
.PHONY: sync
sync:
	@echo "Syncing dependencies..."
	uv sync

# 🛠️ Lock dependencies
.PHONY: lock
lock:
	@echo "Locking dependencies..."
	uv lock

# 🛠️ Remove virtual environment
.PHONY: clean
clean:
	@echo "Removing virtual environment..."
	rm -rf $(VENV_DIR)
	rm -f uv.lock

# 🛠️ Show activation command
.PHONY: activate
activate:
	@echo "To activate the virtual environment, run:"
	@echo "source $(VENV_DIR)/bin/activate"

# 🛠️ Run main application
.PHONY: run
run:
	@echo "Running main application..."
	uv run python main.py

# 🛠️ Run general agent example
.PHONY: run-general
run-general:
	@echo "Running general agent example..."
	uv run python examples/run_general.py

# 🛠️ Run GAIA evaluation
.PHONY: run-gaia
run-gaia:
	@echo "Running GAIA evaluation..."
	uv run python examples/run_gaia.py

# 🛠️ Run tests
.PHONY: test
test:
	@echo "Running tests..."
	uv run pytest tests/test_*.py

# 🛠️ Run all tests
.PHONY: test-all
test-all:
	@echo "Running all tests..."
	uv run pytest tests/

# 🛠️ Check if virtual environment exists
.PHONY: check-env
check-env:
	@echo "Environment info:"
	@echo "Python version: $$(uv run python --version)"
	@echo "uv version: $$(uv --version)"
	@if [ -f "uv.lock" ]; then \
		echo "Lock file: uv.lock exists"; \
	else \
		echo "Lock file: uv.lock not found (run 'make lock')"; \
	fi

# 🛠️ List installed packages
.PHONY: list
list:
	@echo "Installed packages:"
	uv pip list

# 🛠️ Show dependency tree
.PHONY: tree
tree:
	@echo "Dependency tree:"
	uv tree

# 🛠️ Show available Makefile commands
.PHONY: help
help:
	@echo "Makefile commands for uv-based installation:"
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make install             - Install all dependencies using uv sync"
	@echo "  make install-requirements - Install from requirements.txt"
	@echo "  make sync                - Sync dependencies (install missing, remove unused)"
	@echo "  make lock                - Create/update lock file"
	@echo ""
	@echo "Dependency Management:"
	@echo "  make add PKG=name        - Add a new dependency"
	@echo "  make add-dev PKG=name    - Add a new dev dependency"
	@echo "  make remove PKG=name     - Remove a dependency"
	@echo "  make update              - Update all dependencies"
	@echo "  make update-pkg PKG=name - Update specific dependency"
	@echo ""
	@echo "Running Code:"
	@echo "  make run                 - Run main application"
	@echo "  make run-general         - Run general agent example"
	@echo "  make run-gaia            - Run GAIA evaluation"
	@echo "  make test                - Run specific tests"
	@echo "  make test-all            - Run all tests"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean               - Remove virtual environment and lock file"
	@echo "  make activate            - Show activation command"
	@echo "  make check-env           - Check environment status"
	@echo "  make list                - List installed packages"
	@echo "  make tree                - Show dependency tree"
	@echo "  make help                - Show this help message"