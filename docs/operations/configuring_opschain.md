# Configuring OpsChain

This guide describes the various configuration options that can be included in your `.env` file, along with their default values.

## Configuration variables

The following configuration variables can be set in your `.env` file:

_Note: After making changes to your `.env` file, you must run `opschain server configure` and then re-deploy OpsChain (e.g. `opschain server deploy`)._

### Common configuration

| Variable                               | Description                                                                                                                                                                                                                                                     | Default value                                                    |
| :------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------- |
| OPSCHAIN_API_CERTIFICATE_SECRET_NAME   | The [Kubernetes TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) name containing a custom certificate to be used for the HTTPS listener. OPSCHAIN_API_HOST_NAME must also be configured. [Learn more](tls.md#api-certificate) |                                                                  |
| OPSCHAIN_API_EXTERNAL_PORT             | The port that will be exposed for accessing the OpsChain API service.                                                                                                                                                                                           | `3000`                                                           |
| OPSCHAIN_API_HOST_NAME                 | The host name that will be configured for the OpsChain API HTTPS listener. This is not required for HTTP access to the API, only for HTTPS access. [Learn more](tls.md#accessing-the-opschain-api-via-https)                                                    |                                                                  |
| OPSCHAIN_DOCKER_USER                   | Docker Hub username for accessing the OpsChain images.                                                                                                                                                                                                          |                                                                  |
| OPSCHAIN_DOCKER_PASSWORD               | Docker Hub password/token for accessing the OpsChain images.                                                                                                                                                                                                    |                                                                  |
| OPSCHAIN_GID                           | Group ID on the host that should own the OpsChain files.                                                                                                                                                                                                        | GID of the current user (i.e. the output of the `id -g` command) |
| OPSCHAIN_GITHUB_USER                   | OpsChain username for accessing the OpsChain Helm charts via GitHub.                                                                                                                                                                                            |                                                                  |
| OPSCHAIN_GITHUB_TOKEN                  | [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) for accessing the OpsChain Helm charts via GitHub.                                                                                  |                                                                  |
| OPSCHAIN_INSECURE_HTTP_PORT_ENABLED    | Enable/Disable the HTTP ingress port. [Learn more](tls.md#disable-the-insecure-http-listener).                                                                                                                                                                  | true                                                             |
| OPSCHAIN_IMAGE_REGISTRY_HOST           | Internally used hostname that needs to resolve to the Kubernetes node, but be different to the API hostname.                                                                                                                                                    | `opschain-image-registry.local.gd`                               |
| OPSCHAIN_IMAGE_BUILD_ROOTLESS          | Whether to use the [Buildkit rootless mode](https://github.com/moby/buildkit/blob/master/docs/rootless.md#rootless-mode) for the image build container.                                                                                                         | `true`                                                           |
| OPSCHAIN_IMAGE_BUILD_CACHE_VOLUME_SIZE | Volume claim size for the image build container cache.                                                                                                                                                                                                          | `10Gi`                                                           |
| OPSCHAIN_IMAGE_REGISTRY_VOLUME_SIZE    | Volume claim size for the step image registry image storage volume.                                                                                                                                                                                             | `10Gi`                                                           |
| OPSCHAIN_KUBERNETES_NAMESPACE          | [Kubernetes namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) to deploy OpsChain into.                                                                                                                                  | `opschain`                                                       |
| OPSCHAIN_RUNNER_NODE_SELECTOR          | [Kubernetes nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) value that will be used for step runner pods. Must be specified as a JSON string.                                                                           | '{}'                                                             |
| OPSCHAIN_TLS_EXTERNAL_PORT             | The HTTPS listener port on the Kubernetes node. It is also used by OpsChain from the Kubernetes runtime.                                                                                                                                                        | `3443`                                                           |
| OPSCHAIN_UID                           | User ID on the host that should own the OpsChain files.                                                                                                                                                                                                         | UID of the current user (i.e. the output of the `id -u` command) |
| OPSCHAIN_SSH_KNOWN_HOSTS_CONFIG_MAP    | A custom config map name to use for the `.ssh/known_hosts` file. [Learn more](/docs/reference/project_git_repositories.md#customising-the-ssh-known_hosts-file).                                                                                                |                                                                  |

### LDAP configuration

| Variable                      | Description                                                                                                                                                                                                   | Default value               |
| :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :-------------------------- |
| OPSCHAIN_LDAP_ADMIN           | LDAP/AD administrator DN to connect to.<br/> _Note: As OpsChain does not write to the LDAP database, this need only be a DN with permission to search all users and groups._                                  | cn=admin,dc=opschain,dc=io  |
| OPSCHAIN_LDAP_BASE_DN         | LDAP/AD base DN value.                                                                                                                                                                                        | dc=opschain,dc=io           |
| OPSCHAIN_LDAP_DOMAIN          | LDAP/AD domain.                                                                                                                                                                                               | opschain.io                 |
| OPSCHAIN_LDAP_GROUP_BASE      | LDAP/AD base DN to search for groups.                                                                                                                                                                         | ou=groups,dc=opschain,dc=io |
| OPSCHAIN_LDAP_GROUP_ATTRIBUTE | LDAP/AD group attribute containing OpsChain user DNs.                                                                                                                                                         | member                      |
| OPSCHAIN_LDAP_HC_USER         | To verify the LDAP server is available, OpsChain performs a regular query of the LDAP database for the username supplied here. <br/>_Note: If you do not wish to perform this check, leave this blank._       | healthcheck                 |
| OPSCHAIN_LDAP_HOST            | LDAP/AD host name (or IP address).                                                                                                                                                                            | opschain-ldap               |
| OPSCHAIN_LDAP_PASSWORD        | OPSCHAIN_LDAP_ADMIN password.                                                                                                                                                                                 |                             |
| OPSCHAIN_LDAP_PORT            | LDAP/AD host port to connect to.                                                                                                                                                                              | 389                         |
| OPSCHAIN_LDAP_USER_BASE       | LDAP/AD base DN to search for users.                                                                                                                                                                          | ou=users,dc=opschain,dc=io  |
| OPSCHAIN_LDAP_USER_ATTRIBUTE  | LDAP/AD user attribute used as the OpsChain user name.                                                                                                                                                        | uid                         |

### Authentication configuration

| Variable              | Description                                                                                                                                                                                                  | Default value |
| :-------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------ |
| OPSCHAIN_AUTH_SERVICE | Policy agent type on the authorisation host. The following policy agent is currently available: OPA. _Please contact [LimePoint](mailto:opschain-support@limepoint.com) if you require other policy agents._ |               |

### Development environment

The following variables can be manually set inside the OpsChain development environment or configured in your host environment and they will be passed through (e.g. in your `~/.zshrc`).

| Variable                     | Description                                                                                                                                                                                                 | Default value |
| :--------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------ |
| OPSCHAIN_ACTION_RUN_CHILDREN | Automatically run child steps in the local Docker development environment. See the [Docker development environment guide (child steps)](../docker_development_environment.md#child-steps) for more details. | false         |
| OPSCHAIN_TRACE               | If set to true, additional logging will be generated when actions are run                                                                                                                                   | false         |

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
