# Configuring OpsChain

This guide describes the various configuration options that can be included in your `.env` file, along with their default values.

## Configuration variables

The following configuration variables can be set in your `.env` file:

### Common configuration

Variable                    | Description                                                                                                       | Default Value
:-------------------------- | :---------------------------------------------------------------------------------------------------------------- | :--------
OPSCHAIN_DATA_DIR           | Directory where OpsChain stores the container data files, supplied as part of running the `configure` script.     | `./opschain_data`
OPSCHAIN_DOCKER_SOCKET_PATH | Location of the Docker socket file on the Docker host.                                                            | `./var/run/docker.sock`
OPSCHAIN_GID                | Group ID on the Docker host that should own the OpsChain files.                                                   | GID of the current user (i.e. the output of the `id -g` command)
OPSCHAIN_UID                | User ID on the Docker host that should own the OpsChain files.                                                    | UID of the current user (i.e. the output of the `id -u` command)

### LDAP configuration

Variable                      | Description                                               | Default Value
:---------------------------- | :-------------------------------------------------------- | :--------
OPSCHAIN_LDAP_ADMIN           | LDAP/AD administrator DN to connect to.<br/> _Note: As OpsChain does not write to the LDAP database, this need only be a DN with permission to search all users and groups._                               | cn=admin,dc=opschain,dc=io
OPSCHAIN_LDAP_BASE_DN         | LDAP/AD base DN value.                                                                                                                                                                                     | dc=opschain,dc=io
OPSCHAIN_LDAP_DOMAIN          | LDAP/AD domain.                                                                                                                                                                                            | opschain.io
OPSCHAIN_LDAP_ENABLE_SSL      | To connect to the LDAP host using the `ldaps://` protocol, set this to true.<br/> _Note: To use a custom Certificate Authority (CA) see [custom SSL certificates](opschain_ldap#custom-ssl-certificates)._ | false
OPSCHAIN_LDAP_GROUP_BASE      | LDAP/AD base DN to search for groups.                                                                                                                                                                      | ou=groups,dc=opschain,dc=io
OPSCHAIN_LDAP_GROUP_ATTRIBUTE | LDAP/AD group attribute containing OpsChain user DNs.                                                                                                                                                      | member
OPSCHAIN_LDAP_HC_USER         | To verify the LDAP server is available, OpsChain performs a regular query of the LDAP database for the username supplied here. <br/>_Note: If you do not wish to perform this check, leave this blank._    | healthcheck
OPSCHAIN_LDAP_HOST            | LDAP/AD host name (or IP address).                                                                                                                                                                         | opschain-ldap
OPSCHAIN_LDAP_PASSWORD        | OPSCHAIN_LDAP_ADMIN password.                                                                                                                                                                              |
OPSCHAIN_LDAP_PORT            | LDAP/AD host port to connect to.                                                                                                                                                                           | 389
OPSCHAIN_LDAP_USER_BASE       | LDAP/AD base DN to search for users.                                                                                                                                                                       | ou=users,dc=opschain,dc=io
OPSCHAIN_LDAP_USER_ATTRIBUTE  | LDAP/AD user attribute used as the OpsChain user name.                                                                                                                                                     | uid

### Authentication configuration

Variable              | Description                                                                                                                                                                                          | Default Value
:-------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------
OPSCHAIN_AUTH_SERVICE | Policy agent type on the authorisation host. The following policy agent is currently available: OPA. _Please contact [LimePoint](mailto:opschain@limepoint.com) if you require other policy agents._ |

### Log aggregator configuration

Variable                          | Description                                          | Default Value
:-------------------------------- | :--------------------------------------------------- | :--------
OPSCHAIN_LOG_AGGREGATOR_HOST      | Host name (or IP address) of the log aggregator.     | localhost

### Development environment

The following variables can be manually set inside the OpsChain development environment or configured in your `.env` file.

Variable                          | Description                                                               | Default Value
:-------------------------------- | :------------------------------------------------------------------------ | :--------
OPSCHAIN_ACTION_RUN_CHILDREN      | Automatically run child steps in the local Docker development environment. See the [Docker development environment guide (child steps)](../docker_development_environment.md#child-steps) for more details. | false
OPSCHAIN_TRACE                    | If set to true, additional logging will be generated when actions are run | false

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
