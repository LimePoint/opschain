# Restricting user access

Restricting access to OpsChain projects and environments allows you to control user access to view (or perform operations on) OpsChain objects (e.g. properties, changes, logs, etc.).

After following this guide you should know how to:

- enable the OpsChain Open Policy Agent security provider
- view, edit and change the OpsChain security configuration

## Background

The OpsChain access restriction model works on an exclusion basis. That is, users can access all OpsChain objects other than those listed as unauthorised against one or more of their LDAP groups. This ensures new projects and environments are available to users after creation without the need to alter the security configuration.

## Configure OpsChain for authorisation

### Enable authorisation service

By default, the OpsChain authorisation service is disabled. To enable it, edit your `.env` file and set:

```bash
OPSCHAIN_AUTH_SERVICE=OPA
```

After reconfiguring and restarting, OpsChain will use the Open Policy Agent server to authorise all requests:

```bash
opschain server configure
opschain server deploy
```

### Expose OpsChain LDAP and authorisation service server ports

OpsChain authorisation relies on the LDAP groups assigned to each user to determine their access. To add users to groups, you will need to make the LDAP server port available to the host operating system. You will also need to make the authorisation service server port available to the host operating system to enable altering the authorisation service configuration. We suggest only binding the authorisation service port to `localhost` and only doing it whilst actively making changes as this endpoint can be used to update security configuration and is not authenticated. The `--address` argument can be passed to `kubectl port-forward` if you wish to bind it to another address.

To do this, run the `kubectl port-forward` command:

```bash
kubectl port-forward -n opschain deploy/opschain-auth 8181
# open a new terminal
kubectl port-forward -n opschain deploy/opschain-ldap 389
# open a new terminal
```

_Note: this step assumes you are using the default `opschain` Kubernetes namespace for OpsChain._

## Restricting project and environment access

The following example assumes you have completed the [getting started](../getting_started/README.md) guide. The example security configuration makes use of projects and environments created as part of the [Terraform](../examples/running_a_simple_terraform_change.md), [Confluent](../examples/running_a_complex_change.md) and [Ansible](../examples/running_an_aws_ansible_change.md) examples. These will help to highlight the restrictions applied to OpsChain but are not necessary to complete the example.

### List project environments

List the `demo` project environments to verify the `dev` environment is available:

```bash
opschain environment list -p demo
```

### Update the security configuration

When OpsChain is started, it initialises its security configuration from the `security_configuration.json` file. An empty configuration file was created when you ran the `opschain server configure` command. Edit this file, replacing the contents with the following JSON:

```json
{
  "group_unauthorised_projects": {
    "ldap-group-1": ["ansible"]
  },
  "group_unauthorised_environments": {
    "ldap-group-1": ["dev"],
    "ldap-group-2": ["local", "tform"]
  }
}
```

The JSON above will:

1. restrict users in `ldap-group-1` from all OpsChain objects related to the `ansible` project and all objects related to the `dev` environment
2. restrict users in `ldap-group-2` from all OpsChain objects related to the `local` and `tform` environments

_Note: The `security_configuration.json` file is case sensitive - all keys and codes must be lowercase._

Upload the new configuration to the authorisation server:

```bash
curl -k http://localhost:8181/v1/data -H "Content-Type: application/json" -X PUT -d "@./security_configuration.json"
```

### Assign LDAP group

Add the `opschain` user to the `ldap-group-1` group. This can be done manually using an LDAP editor (such as [Apache Directory Studio](https://directory.apache.org/studio/) or [LDAP Browser for MAC](http://www.ldapbrowsermac.com/)), or by importing the following LDIF file:

```ldif
version: 1

dn: cn=ldap-group-1,ou=groups,dc=opschain,dc=io
changetype: add
cn: Security Group 1
objectclass: groupOfNames
member: uid=opschain,ou=users,dc=opschain,dc=io
```

_Note: You can connect to the LDAP server at `localhost:389`. The administrator username and password are available in your `.env` file - see the `OPSCHAIN_LDAP_ADMIN` and `OPSCHAIN_LDAP_PASSWORD` values._

### Confirm access restrictions

After assigning `opschain` to `ldap-group-1`, re-run the environment list command, verifying the `dev` environment is no longer displayed:

```bash
opschain environment list -p demo
```

Try creating a change to run the `hello_world` action, noting that the change creation fails as the environment is not found:

```bash
opschain change create -p demo -e dev -a hello_world -c master --confirm
```

## Combining group restrictions

If an OpsChain user is assigned to multiple LDAP groups, the user is restricted from accessing all projects and environments associated with all of those groups. Add the `opschain` user to `ldap-group-2` (`opschain` should now be part of `ldap-group-1` and `ldap-group-2`). Verify that the above restrictions remain in place, and in addition, `opschain` is also restricted from interacting with the `tform` or `local` environments.

## Notes on security configuration

1. The `security_configuration.json` is read each time OpsChain is started (`docker-compose up`). POSTing the file to the server (using the `curl` command listed above) allows this configuration to be changed without needing to restart OpsChain.

    _Note: Changes POSTed to the server that are not replicated in the `security_configuration.json` file will be lost on OpsChain restart._

2. Issuing a GET request to the `http://localhost:8181/v1/data` endpoint will return the current configuration.

## Cleaning up

Once you have updated your configuration, terminate the `kubectl port-forward` processes started at the [beginning of this guide](#expose-opschain-ldap-and-authorisation-service-server-ports) (e.g. by hitting `ctrl-c` in each of those terminals).

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
