# OpsChain CLI reference

This document provides information on obtaining, configuring and using the OpsChain CLI.

When configuring the CLI, please note that some of the options described are optional and may not be required depending on your operating environment.

## OpsChain CLI download

The OpsChain CLI binary can be downloaded from the `opschain-trial` repository on [GitHub](https://github.com/LimePoint/opschain-trial/releases). Ensure the native build matches the version of OpsChain that you are using.

After downloading the binary you may need to make it executable (this is required on macOS or Linux):

```bash
chmod +x opschain*
```

Please note that:

- the `.opschainrc` configuration will need to be modified to update the `apiBaseUrl` (likely to `http://localhost:3000/`, assuming a local OpsChain install and the default 3000 port)
- the native binaries are currently a release preview and offer support for the latest version of the respective OS on a best effort basis (older versions of the respective OS may work)
- unlike the OpsChain CLI container, you will need to manually update the native binary whenever you upgrade your OpsChain installation

_Note: On macOS you may need to trust the OpsChain CLI binary as it is not currently signed. See [the Apple documentation](https://support.apple.com/en-au/guide/mac-help/mh40616/mac) for details._

## OpsChain CLI configuration

The OpsChain CLI uses an `.opschainrc` configuration file. If `.opschainrc` is present in the current working directory it is used, otherwise, the `.opschainrc` from the user's home directory is used.

An [example .opschainrc](../../.opschainrc.example) is provided in this repository.

The configuration file supports INI or JSON (with comments) formats.

### Native CLI binary configuration

With native builds the OpsChain configuration is loaded by the `rc` package. The [`rc` documentation](https://www.npmjs.com/package/rc#standards) specifies the locations where the configuration file can be placed - the `appname` is `opschain`.

_On Windows the `USERPROFILE` directory is used as the home directory._

### OpsChain CLI configuration settings

The `.opschainrc` file must be valid JSON and supports the following configuration:

| Configuration Key | Optional | Description                                                                               |
| :---------------- | :------- | :---------------------------------------------------------------------------------------- |
| `apiBaseUrl`      | no       | OpsChain API server URL                                                                   |
| `username`        | no       | OpsChain API username                                                                     |
| `password`        | no       | OpsChain API password                                                                     |
| `stepEmoji`       | yes      | show emoji for the step status, default `true` - set to `false` to display status as text |
| `projectCode`     | yes      | default OpsChain project code used for commands                                           |
| `environmentCode` | yes      | default OpsChain environment code used for commands                                       |

### Environment variable configuration

OpsChain configuration can be overridden by using environment variables. This can be useful for temporarily overriding configuration.

Prefix the configuration key with `opschain_` and set as an environment variable to override the value from the `.opschainrc`.

```bash
export opschain_projectCode=dev
opschain environment ls # this will list environments in the dev project without prompting
```

## Using the OpsChain CLI with a proxy

_Note: this is only required if you are using an OpsChain server that needs to be accessed via a proxy. It is not mandatory._

The OpsChain CLI supports using a http(s) proxy by setting the relevant environment variables:

```bash
export HTTP_PROXY=http://localhost:8080
export HTTPS_PROXY=http://localhost:8080
opschain change ls # or any other command
```

`HTTP_PROXY` is used when the OpsChain `apiBaseUrl` is an HTTP address. `HTTPS_PROXY` is used when the OpsChain `apiBaseUrl` is an HTTPS address.

## Disabling TLS/SSL certificate verification

_Note: this is only required if you are using an OpsChain server that uses a non-trusted certificate. It is not mandatory._

The OpsChain CLI can be configured to ignore TLS/SSL certificate verification errors as follows:

```bash
export NODE_TLS_REJECT_UNAUTHORIZED=0
opschain change ls # or any other command
```

## OpsChain CLI container image

The OpsChain CLI is also distributed as a container image, `limepoint/opschain-cli:${OPSCHAIN_IMAGE_TAG}` - where OPSCHAIN_IMAGE_TAG is in the `.env` file in the `opschain-trial` directory.

Some examples of how the CLI image can be used are shown below:

```bash
docker run -ti -v ~/.opschainrc:$(pwd)/.opschainrc limepoint/opschain-cli:${OPSCHAIN_IMAGE_TAG} environment ls
# with files:
docker run -ti -v $(pwd):$(pwd) -v ~/.opschainrc:$(pwd)/.opschainrc -w $(pwd) limepoint/opschain-cli:${OPSCHAIN_IMAGE_TAG} environment set-properties -f ./properties.json
```

### Using the OpsChain CLI in an OpsChain change

The OpsChain CLI container image also makes it simple to access the OpsChain CLI within a [custom step runner Dockerfile](concepts/step_runner.md#custom-step-runner-dockerfiles):

```dockerfile
ARG OPSCHAIN_IMAGE_TAG
ARG OPSCHAIN_BASE_RUNNER
FROM limepoint/opschain-cli:${OPSCHAIN_IMAGE_TAG} as cli
FROM ${OPSCHAIN_BASE_RUNNER}

...

COPY --from=cli /opschain /usr/bin/opschain
```

The CLI configuration can be included in the [environment variable properties](concepts/properties.md#environment-variables) using the [environment variable configuration](#environment-variable-configuration)

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
