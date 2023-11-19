# Derived from official mysql image (our base image)
FROM mysql:5.7.20

# Add a database
ENV MYSQL_DATABASE wordpress
ENV MYSQL_PORT 3306

# Add the content of the sql-scripts/ directory to your image
# All scripts in docker-entrypoint-initdb.d/ are automatically
# executed during container startup
COPY sql /docker-entrypoint-initdb.d/

