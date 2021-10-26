# OpsChain LDAP

OpsChain can utilise an LDAP database for user authorisation and authentication. After following this guide you should know how to:

- adjust OpsChain's LDAP group membership caching feature
- configure OpsChain to use an external LDAP/AD database

---

## LDAP group membership caching

The OpsChain [security model](restricting_user_access.md) uses the LDAP groups a user is a member of to restrict their access to projects and environments. For this reason, each request to the OpsChain API server necessitates an LDAP query. By default, OpsChain will cache a user's LDAP group membership for 1 minute to reduce the volume of LDAP requests.

### Disable caching

To disable group membership caching, set the `OPSCHAIN_LDAP_CACHE_TTL` value to `0` in your `.env` file.

```bash
echo OPSCHAIN_LDAP_CACHE_TTL=0 >> .env
```

### Increase cache life

To increase the cache life, set the `OPSCHAIN_LDAP_CACHE_TTL` value to the number of seconds you would like the cache to be valid. The following example would increase the cache life to 5 minutes.

```bash
echo OPSCHAIN_LDAP_CACHE_TTL=300 >> .env
```

---

## Configuring an external LDAP

This guide takes you through how to use an external LDAP server with OpsChain.

After following this guide you should know how to:

- configure OpsChain to use an external LDAP server for authentication
- disable the supplied OpsChain LDAP server

### Shutdown OpsChain

Please ensure OpsChain is not running before making changes to the LDAP configuration.

```bash
docker-compose down
```

### OpsChain LDAP configuration

See the [Configuring OpsChain](configuring_opschain.md#ldap-configuration) guide for details of the LDAP configuration variables that can be adjusted to enable the use of an external LDAP server. An example Active Directory configuration appears at the end of this document.

### Disable the supplied OpsChain LDAP server

By default, OpsChain will use the LDAP server on the `opschain-ldap` container for user authentication. When using an external LDAP server, create (or modify your existing) `docker-compose.override.yml` to ensure the `opschain-ldap` container is not started.

Create the `docker-compose.override.yml` file as follows:

```bash
cat << EOF > docker-compose.override.yml
version: '2.4'

services:
  opschain-ldap:
    scale: 0
EOF
```

_Note: If you have already created an override file for other reasons insert the `scale: 0` entry manually to avoid overwriting your file._

### Restart OpsChain

After verifying the LDAP configuration and override file, restart the OpsChain environment:

```bash
docker-compose up
```

### Custom SSL certificates

The OpsChain API server can use a custom certificate authority (CA) and/or a custom certificate path if required.

#### Overriding the default CA file

Install the custom certificate authority into `<OPSCHAIN_DATA>/certs/ca.pem`. If the file exists, OpsChain will configure the environment variable [`SSL_CERT_FILE=<OPSCHAIN_DATA>/certs/ca.pem`](https://www.openssl.org/docs/manmaster/man7/openssl-env.html#SSL_CERT_DIR-SSL_CERT_FILE) on the API server.

_Note: OpsChain requires the CA certificate be named `ca.pem` otherwise it will be ignored._

#### Overriding the default certificate directory

Create a `cert_dir` folder within `<OPSCHAIN_DATA>/certs` and place the additional certificate and keys here. If the directory exists, OpsChain will configure the environment variable [`SSL_CERT_DIR=<OPSCHAIN_DATA>/certs/cert_dir`](https://www.openssl.org/docs/manmaster/man7/openssl-env.html#SSL_CERT_DIR-SSL_CERT_FILE) on the API server.

### Example Active Directory configuration

The following example `.env` values allow OpsChain to utilise an Active Directory for user authentication:

```dotenv
OPSCHAIN_LDAP_HOST=ad-server
OPSCHAIN_LDAP_PORT=389
OPSCHAIN_LDAP_DOMAIN=myopschain.io
OPSCHAIN_LDAP_BASE_DN=DC=myopschain,DC=io
OPSCHAIN_LDAP_USER_BASE=CN=Users,DC=myopschain,DC=io
OPSCHAIN_LDAP_USER_ATTRIBUTE=sAMAccountName
OPSCHAIN_LDAP_GROUP_BASE=DC=myopschain,DC=io
OPSCHAIN_LDAP_GROUP_ATTRIBUTE=member
OPSCHAIN_LDAP_ADMIN=CN=Administrator,CN=Users,DC=myopschain,DC=io
OPSCHAIN_LDAP_PASSWORD=AdministratorPassword!
OPSCHAIN_LDAP_HC_USER=
OPSCHAIN_LDAP_ENABLE_SSL=false
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
