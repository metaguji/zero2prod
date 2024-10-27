#!/usr/bin/env bash
set -x
set -eo pipefail

if ! [ -x "$(command -v sqlx)" ]; then
    echo >&2 "Error: sqlx is not installed."
    exit 1
fi

DB_PORT="${POSTGRES_PORT:=5432}"
SUPERUSER="${SUPERUSER:=postgres}"
SUPERUSER="${SUPERUSER_PWD:=password}"

APP_USER="${APP_USER:=app}"
APP_USER_PWD="${APP_USER_PWD:=secret}"
APP_DB_NAME="${APP_DB_NAME:=newsletter}"

if [[ -z "${SKIP_DOCKER}" ]]
then
    CONTAINER_NAME="postgres"
    # docker run \
    #     --env POSTGRES_USER=${SUPERUSER} \
    #     --env POSTGRES_PASSWORD=${SUPERUSER_PWD} \
    #     --publish "${DB_PORT}":5432 \
    #     --detach \
    #     --name "${CONTAINER_NAME}" \
    #     postgres -N 1000

    until [ \
        "$(docker inspect -f "{{.State.Status}}" ${CONTAINER_NAME})" == "running" \
    ]; do
        >&2 echo "Postgres is still unavailable - sleeping"
        sleep 1
    done

    # CREATE_QUERY="CREATE USER ${APP_USER} WITH PASSWORD '${APP_USER_PWD}';"
    # docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${CREATE_QUERY}"

    # GRANT_QUERY="ALTER USER ${APP_USER} CREATEDB;"
    # docker exec -it "${CONTAINER_NAME}" psql -U "${SUPERUSER}" -c "${GRANT_QUERY}"
fi

>&2 echo "Postgres is up and running on post ${DB_PORT}!"

DATABASE_URL=postgres://$(APP_USER):$(APP_USER_PWD)@localhost:$(DB_PORT)/$(APP_DB_NAME)
export DATABASE_URL
sqlx database create
sqlx migrate run

>&2 echo "Postgres has been migrated, ready to go!"