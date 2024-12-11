
## Original Dockerfile Mistakes and Fixes

### Mistake 1: PostgreSQL Installation Errors
The original Dockerfile attempted to install PostgreSQL using `apt-get install -y postgresql`

**Fix**: Added the official PostgreSQL repository to ensure the latest version is installed:

RUN apt-get update && \
    apt-get install -y gnupg2 curl lsb-release && \
    curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c | awk '{print $2}')-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y postgresql-13 postgresql-contrib && \
    rm -rf /var/lib/apt/lists/*


### Mistake 2: Incorrect Path for Configuration Files
The original Dockerfile used the path `/etc/postgresql/13/main/postgresql.conf.sample` for modifying the `listen_addresses` setting, which does not exist in the installed PostgreSQL version.

**Fix**: Updated the path to the correct `postgresql.conf` file:

RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf && \
    echo "host all all 0.0.0.0/0 trust" >> /etc/postgresql/13/main/pg_hba.conf


### Mistake 3: Incorrect CMD to Start PostgreSQL
Initial CMD failed because the executable `postgres` was not in the `PATH` and the data directory was not properly initialized.

**Fix**: Used the full path to the `postgres` executable and ensured the data directory is properly initialized:

CMD ["/usr/lib/postgresql/13/bin/postgres", "-D", "/var/lib/postgresql/13/main"]


### Mistake 5: Ignoring Cleanup for Unnecessary Packages
The original Dockerfile did not remove unnecessary files after installation, resulting in a larger image size.

**Fix**: Added cleanup commands to remove unused package lists and temporary files:

rm -rf /var/lib/apt/lists/*


These fixes ensure that the Docker image is secure, functional, and adheres to best practices.



Extra credit 2:
To implement a secret encryption solution for PostgreSQL credentials, Docker can use secrets or environment variable injection through a secret management tool such as AWS Secrets Manager or Docker Secrets to avoid hardcoded secrets in Dockerfile. For this i would implement following steps:
    - modify Dockerfile to use variables instead of hardcoded values for secrets
    - create separate .sh file to read secrets and initialize Postgress accordingly
    - create Docker secrets to store sensitive data
    - use Docker Compose to inject secrets into containers