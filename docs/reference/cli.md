# OpsChain CLI Reference

## OpsChain CLI Configuration

The OpsChain CLI uses an `.opschainrc` configuration file. If `.opschainrc` is present in the current working directory it is used, otherwise, the `.opschainrc` from the user's home directory is used.

An [example .opschainrc](../../.opschainrc.example) is provided in this repository.

### OpsChain CLI Configuration Settings

The `.opschainrc` file must be valid JSON and supports the following configuration:

| Configuration Key | Optional | Description                                         |
| :---------------- | :------- | :-------------------------------------------------- |
| `apiBaseUrl`      | no       | OpsChain API server URL                             |
| `username`        | no       | OpsChain API username                               |
| `password`        | no       | OpsChain API password                               |
| `projectCode`     | yes      | default OpsChain project code used for commands     |
| `environmentCode` | yes      | default OpsChain environment code used for commands |

### Environment Variable Configuration

OpsChain configuration can be overridden by using environment variables. This can be useful for temporarily overriding configuration.

Prefix the configuration key with `opschain_` and set as an environment variable to override the value from the `.opschainrc`.

```bash
$ export opschain_projectCode=dev
$ opschain environment ls # this will list environments in the dev project without prompting
```

## Using the OpsChain CLI with a Proxy

The OpsChain CLI supports using a http(s) proxy by setting the relevant environment variables:

```bash
$ export HTTP_PROXY=http://localhost:8080
$ export HTTPS_PROXY=http://localhost:8080
$ opschain change ls # or any other command
```

`HTTP_PROXY` is used when the OpsChain `apiBaseUrl` is an HTTP address. `HTTPS_PROXY` is used when the OpsChain `apiBaseUrl` is an HTTPS address.

## Disabling TLS/SSL Certificate Verification

The OpsChain CLI can be configured to ignore TLS/SSL certificate verification errors as follows:

```bash
$ export NODE_TLS_REJECT_UNAUTHORIZED=0
$ opschain change ls # or any other command
```
