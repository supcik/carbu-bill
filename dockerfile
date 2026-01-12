FROM python:3

ARG TARGETARCH

ENV POETRY_VERSION=2.2.1 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_NO_INTERACTION=1 \
    TYPST_VERSION=0.14.2

WORKDIR /app
COPY pyproject.toml poetry.lock /app/
COPY carbu /app/carbu
COPY fonts /app/fonts
COPY typst-templates /app/typst-templates

RUN pip install "poetry==$POETRY_VERSION"
RUN poetry install --no-root --without dev --no-interaction --no-ansi

RUN pip install gunicorn

# Install typst for the correct architecture
RUN if [ "$TARGETARCH" = "amd64" ]; then \
    TYPST_ARCH="x86_64-unknown-linux-musl"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
    TYPST_ARCH="aarch64-unknown-linux-musl"; \
    else \
    echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    curl -L https://github.com/typst/typst/releases/download/v$TYPST_VERSION/typst-${TYPST_ARCH}.tar.xz | tar xJ -C /tmp && \
    mv /tmp/typst-${TYPST_ARCH}/typst /usr/bin/typst 

CMD [ "gunicorn", "--threads", "4", "--bind", "0.0.0.0:8000", "carbu:app" ]