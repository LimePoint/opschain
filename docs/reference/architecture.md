# Architecture Overview

OpsChain provides a fully self contained environment consisting of the command line interface (CLI), API server, a PostgreSQL database and a Fluentd log aggregator. An optional LDAP server is also provided to make it easy to get started, however it is envisaged that most customers will have their own central LDAP server to integrate with in a production deployment.

Each part of this environment is deployed using [Docker Compose](https://docs.docker.com/compose/), see `docker-compose.yml` for more details.

<p align="center">
  <img alt="OpsChain containers" src="opschain-release-containers.svg">
</p>

- **cli** is a command line client that can be used to interact with the API, it has been packaged as a container for ease of use
- **api** is a [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) API that uses the [json:api](https://jsonapi.org/) format
- **api-worker** is a collection of containers that will perform long running tasks
- **log-aggregator** accepts log output from the workers and ships it to the API where it can then be accessed
- **ldap** is a lightweight LDAP server that is used for authorisation and authentication
- **db** is the inbuilt database used by both the API and its workers
- **runner** represents the transient containers that will be spawned by the workers to complete each step

## Licence & Authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
