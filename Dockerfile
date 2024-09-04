FROM python:3.12-slim as python-base

# python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_VERSION=1.0.3 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# install system dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
        libpq-dev gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install poetry
RUN pip install poetry

# set up the project
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# install runtime dependencies
RUN poetry install --only main

# set the working directory
WORKDIR /app

# copy the rest of the project files
COPY . /app/

# expose the port
EXPOSE 8080

# run the application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8080"]
