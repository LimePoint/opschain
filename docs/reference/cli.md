# OpsChain CLI reference

## OpsChain CLI configuration

The OpsChain CLI uses an `.opschainrc` configuration file. If `.opschainrc` is present in the current working directory it is used, otherwise, the `.opschainrc` from the user's home directory is used.

An [example .opschainrc](../../.opschainrc.example) is provided in this repository.

### Native CLI binary configuration

With native builds the OpsChain configuration is loaded by the `rc` package. The [`rc` documentation](https://www.npmjs.com/package/rc#standards) specifies the locations where the configuration file can be placed - the `appname` is `opschain`.

_On Windows the `USERPROFILE` directory is used as the home directory._

### OpsChain CLI configuration settings

The `.opschainrc` file must be valid JSON and supports the following configuration:

Configuration Key | Optional | Description
:---------------- | :------- | :--------------------------------------------------
`apiBaseUrl`      | no       | OpsChain API server URL
`username`        | no       | OpsChain API username
`password`        | no       | OpsChain API password
`projectCode`     | yes      | default OpsChain project code used for commands
`environmentCode` | yes      | default OpsChain environment code used for commands

### Environment variable configuration

OpsChain configuration can be overridden by using environment variables. This can be useful for temporarily overriding configuration.

Prefix the configuration key with `opschain_` and set as an environment variable to override the value from the `.opschainrc`.

```bash
export opschain_projectCode=dev
opschain environment ls # this will list environments in the dev project without prompting
```

## Using the OpsChain CLI with a proxy

The OpsChain CLI supports using a http(s) proxy by setting the relevant environment variables:

```bash
export HTTP_PROXY=http://localhost:8080
export HTTPS_PROXY=http://localhost:8080
opschain change ls # or any other command
```

`HTTP_PROXY` is used when the OpsChain `apiBaseUrl` is an HTTP address. `HTTPS_PROXY` is used when the OpsChain `apiBaseUrl` is an HTTPS address.

## Disabling TLS/SSL certificate verification

The OpsChain CLI can be configured to ignore TLS/SSL certificate verification errors as follows:

```bash
export NODE_TLS_REJECT_UNAUTHORIZED=0
opschain change ls # or any other command
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
