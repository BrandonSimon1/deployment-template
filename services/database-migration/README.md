This repository is a template for managing the state of a posgres database in raw sql using the db-migrate library. Initial migrations have been provided that initialize the database for use with postgraphile. Please see the migrations folder. See the package.json for available commands.

The database connection information is passed through the environment; please see config.json for details.

The Dockerfile will build an image which will upgrade the database and then exit. I would deploy this inside kubernetes or docker-compose alongside the applicaton and database.

Fork the repo and add a github action to build and push the image on commit.
