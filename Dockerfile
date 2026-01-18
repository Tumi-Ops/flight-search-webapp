# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.14.0
FROM python:${PYTHON_VERSION}-slim AS base

WORKDIR /app

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

ENV API_GATEWAY_URL="https://ldxejcs56d.execute-api.eu-north-1.amazonaws.com"
ENV COGNITO_CLIENT_ID="5n1qsvctt1fehq07dida9sbij7"
ENV OIDC_AUTHORITY_URL="https://cognito-idp.eu-north-1.amazonaws.com/eu-north-1_Y9IgDZbnY"

COPY . .

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt 
    
# Switch to the non-privileged user to run the application.
USER appuser

EXPOSE 5000

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "main:app"]
