# inventory_tracker_db Dockerfile
#
# Uses the official Postgres image and adds the initdb SQL so schema is created
# on first boot (when /var/lib/postgresql/data is empty).
#
# Note: docker-compose.yml can either use this Dockerfile (build) or the official
# image directly. Building can be convenient for packaging init scripts with the
# image; using the official image is also perfectly valid.

FROM postgres:16-alpine

# Copy initialization SQL scripts
# These run in alphabetical order on first initialization only.
COPY docker/initdb/ /docker-entrypoint-initdb.d/
