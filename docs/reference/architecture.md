# Architecture overview

OpsChain provides a fully self contained environment consisting of the command line interface (CLI), API server, PostgreSQL database, Fluentd log aggregator, Open Policy Agent authorisation server and an optional LDAP server. The [configuring an external LDAP](../operations/configuring_external_ldap.md) guide provides instructions to swap out the OpsChain LDAP and integrate with a centralised LDAP or Active Directory server.

Each part of this environment is deployed using [Docker Compose](https://docs.docker.com/compose/), see `docker-compose.yml` for more details.

<p align="center">
  <img alt="OpsChain containers" src="opschain-release-containers.svg">
</p>

- **cli** is a command line client that can be used to interact with the API, it has been packaged as a container for ease of use (native clients for Windows, macOS & Linux are available as a feature preview upon request)
- **api** is a [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer) API that uses the [json:api](https://jsonapi.org/) format
- **api-worker** is a collection of containers that will perform long running tasks
- **auth** is the inbuilt authorisation server used by the API
- **db** is the inbuilt database used by both the API and its workers
- **ldap** is a lightweight LDAP server that is used for authentication
- **log-aggregator** accepts log output from the workers and ships it to the API where it can then be accessed
- **runner** represents the transient containers that will be spawned by the workers to complete each step

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
