# FROM ubuntu:latest

# # Set non-interactive frontend to avoid prompts
# ENV DEBIAN_FRONTEND=noninteractive

# # Update package repository, install PostgreSQL, and clean up
# RUN apt-get update && \
#     apt-get install -y gnupg2 curl lsb-release && \
#     # Add PostgreSQL APT repository
#     curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
#     echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c | awk '{print $2}')-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
#     apt-get update && \
#     apt-get install -y postgresql-13 postgresql-contrib && \
#     rm -rf /var/lib/apt/lists/*

# # Modify postgresql.conf to allow connections from all IP addresses
# RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf && \
#     echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/13/main/pg_hba.conf

# # Create a new PostgreSQL user and database
# RUN service postgresql start && \
#     su - postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\"" && \
#     su - postgres -c "createdb -O myuser mydatabase"

# # Expose the PostgreSQL default port
# EXPOSE 5432

# # Start PostgreSQL in the background
# CMD ["postgres", "-D", "/etc/postgresql/13/main"]

FROM ubuntu:latest

# Set non-interactive frontend to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package repository, install PostgreSQL, and clean up
RUN apt-get update && \
    apt-get install -y gnupg2 curl lsb-release && \
    # Add PostgreSQL APT repository
    curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c | awk '{print $2}')-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-13 postgresql-contrib && \
    rm -rf /var/lib/apt/lists/*

# Modify postgresql.conf to allow connections from all IP addresses
RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf && \
    echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/13/main/pg_hba.conf

# Create a new PostgreSQL user and database
RUN service postgresql start && \
    su - postgres -c "psql -c \"CREATE USER myuser WITH PASSWORD 'mypassword';\"" && \
    su - postgres -c "createdb -O myuser mydatabase"

# Expose the PostgreSQL default port
EXPOSE 5432

# Start PostgreSQL
CMD ["/usr/lib/postgresql/13/bin/postgres", "-D", "/var/lib/postgresql/13/main"]

