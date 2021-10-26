# OpsChain CLI reference

## OpsChain native CLI

The `opschain` command in the `opschain-trial` repository uses a Docker container to run the OpsChain CLI. As such this command requires the host have a working Docker installation. As an alternative, OpsChain offers native builds of the OpsChain CLI for Windows, macOS and Linux.

The native binary offers several benefits over the Docker command:

- the host does not need to have Docker installed
- better startup performance
- the binary can be distributed to users that do not have access to the `opschain-trial` repository
- the `cli-files` directory does not need to be used - any files can be used directly

The native binary can be downloaded from the `opschain-trial` repository on [GitHub](https://github.com/LimePoint/opschain-trial/releases). Ensure the native build matches the version of OpsChain that you are using.

After downloading the binary you may need to make it executable (this is required on macOS or Linux):

```bash
chmod +x opschain*
```

Please note that:

- the `.opschainrc` configuration will need to be modified to update the `apiBaseUrl` (likely to `http://localhost:3000/`, assuming a local OpsChain install and the default 3000 port)
- the native binaries are currently a release preview and offer support for the latest version of the respective OS on a best effort basis (older versions of the respective OS may work)
- unlike the OpsChain CLI container, you will need to manually update the native binary whenever you upgrade your OpsChain installation

## OpsChain CLI configuration

The OpsChain CLI uses an `.opschainrc` configuration file. If `.opschainrc` is present in the current working directory it is used, otherwise, the `.opschainrc` from the user's home directory is used.

An [example .opschainrc](../../.opschainrc.example) is provided in this repository.

The configuration file supports INI or JSON (with comments) formats.

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
`stepEmoji`       | yes      | show emoji for the step status, default `true` - set to `false` to display status as text
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

See [LICENCE](/LICENCE.md)
