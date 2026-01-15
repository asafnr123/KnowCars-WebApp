
FROM mysql:8.0-oraclelinux8


# copy init script to docker's build-in init dir 
COPY ./init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306
