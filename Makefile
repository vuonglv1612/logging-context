.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")
USING_POETRY=$(shell grep "tool.poetry" pyproject.toml && echo "yes")

.PHONY: help
help:             ## Show the help.
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@fgrep "##" Makefile | fgrep -v fgrep

.PHONY: virtualenv
virtualenv:       ## Create a virtual environment.
	@if [ "$(USING_POETRY)" ]; then poetry install && exit; fi
	@echo "creating virtualenv ..."
	@rm -rf .venv
	@virtualenv -p 3.6 .venv
	@./.venv/bin/pip install -U pip
	@echo
	@echo "!!! Please run 'source .venv/bin/activate' to enable the environment !!!"

.PHONY: show
show:             ## Show the current environment.
	@echo "Current environment:"
	@if [ "$(USING_POETRY)" ]; then poetry env info && exit; fi
	@echo "Running using $(ENV_PREFIX)"
	@$(ENV_PREFIX)python -V
	@$(ENV_PREFIX)python -m site

.PHONY: install
install:          ## Install the project in dev mode.
	@if [ "$(USING_POETRY)" ]; then poetry install && exit; fi
	@echo "Don't forget to run 'make virtualenv' if you got errors."
	@echo "Don't forget to run 'source .venv/bin/activate' to enable the environment before installing"
	@echo -n "Press [ENTER] to continue..."
	@read anykeys
	$(ENV_PREFIX)pip install -e .[dev]

.PHONY: format
format:              ## Format code using black & isort.
	$(ENV_PREFIX)isort logging_context/
	$(ENV_PREFIX)isort tests/
	$(ENV_PREFIX)black logging_context/
	$(ENV_PREFIX)black tests/


.PHONY: lint
lint:             ## Run black, mypy, pylint linters.
	$(ENV_PREFIX)isort --check-only logging_context/
	$(ENV_PREFIX)isort --check-only tests/
	$(ENV_PREFIX)black --check logging_context/
	$(ENV_PREFIX)black --check tests/
	$(ENV_PREFIX)pylint logging_context/
	$(ENV_PREFIX)mypy logging_context/


.PHONY: format_changes
format_changes:              ## Format code using darker & isort.
	$(ENV_PREFIX)darker


.PHONY: lint_changes
lint_changes:             ## Run black, mypy, pylint linters.
	$(ENV_PREFIX)darker --lint pylint --lint mypy --check

.PHONY: test
test: lint        ## Run tests and generate coverage report.
	$(ENV_PREFIX)pytest -v --cov-config .coveragerc --cov=project_name -l --tb=short --maxfail=1 tests/
	$(ENV_PREFIX)coverage html


.PHONY: clean
clean:            ## Clean unused files.
	@find ./ -name '__pycache__' -exec rm -rf {} \;
	@rm -rf .cache
	@rm -rf .pytest_cache
	@rm -rf .mypy_cache
	@rm -rf build
	@rm -rf dist
	@rm -rf *.egg-info
	@rm -rf htmlcov
	@rm -rf .coverage
	@rm -rf .tox/
	@rm -rf docs/_build


.PHONY: release
release:          ## Create a new tag for release.
	@echo "WARNING: This operation will create a version tag"
	@echo "Don't forget to run 'source .venv/bin/activate' to enable the environment before release"
	@echo -n "Press [ENTER] to continue..."
	@read anykeys
	@read -p "Version? (provide the next x.y.z semver) : " TAG
	@echo "creating git tag : $${TAG}"
	@git tag $${TAG}
	@echo "$${TAG}" > logging_context/VERSION
	@$(ENV_PREFIX)gitchangelog > HISTORY.md
	@git add logging_context/VERSION HISTORY.md
	@git commit -m "release: version $${TAG} 🚀"


.PHONY: switch-to-poetry
switch-to-poetry: ## Switch to poetry package manager.
	@echo "Switching to poetry ..."
	@if ! poetry --version > /dev/null; then echo 'poetry is required, install from https://python-poetry.org/'; exit 1; fi
	@rm -rf .venv
	@poetry init --no-interaction --name=a_flask_test --author=rochacbruno
	@echo "" >> pyproject.toml
	@echo "[tool.poetry.scripts]" >> pyproject.toml
	@echo "logging_context = 'logging_context.main:main'" >> pyproject.toml 
	@cat requirements.txt | while read in; do poetry add --no-interaction "$${in}"; done
	@cat requirements-base.txt | while read in; do poetry add --no-interaction "$${in}" --dev; done
	@cat requirements-test.txt | while read in; do poetry add --no-interaction "$${in}" --dev; done
	@poetry install --no-interaction
