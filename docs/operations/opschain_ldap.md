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

### Disable the supplied OpsChain LDAP server

By default, OpsChain will use the LDAP server in the `opschain-ldap` pod for user authentication. To disable the opschain-ldap service, edit `values.yaml` and alter the `ldap` `enabled` setting to be false.

```yaml
  ldap:
    enabled: false
```

_Note: This setting will be applied to the Kubernetes cluster when you [restart OpsChain API](#restart-opschain-api) after altering the LDAP configuration._

### Alter the OpsChain LDAP configuration

See the [configuring OpsChain](configuring_opschain.md#ldap-configuration) guide for details of the LDAP configuration variables that can be adjusted to enable the use of an external LDAP server. Edit your `.env` file, adding the relevant LDAP options to override the default values supplied in `.env.internal`.

_Note: An example [Active Directory configuration](#example-active-directory-configuration) appears at the end of this document._

### Restart OpsChain API

Restart the OpsChain API server to allow the new LDAP configuration to take effect.

```bash
kubectl rollout restart -n opschain deployment.apps/opschain-api
```

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
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
