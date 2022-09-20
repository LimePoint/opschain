# OpsChain CLI reference

This document provides information on obtaining, configuring and using the OpsChain CLI.

When configuring the CLI, please note that some of the options described are optional and may not be required depending on your operating environment.

## Installation

The OpsChain CLI binary can be downloaded from the `opschain` repository on [GitHub](https://github.com/LimePoint/opschain/releases). Ensure the native build matches the version of OpsChain that you are using. We suggest moving the binary to a location in your `PATH` to ensure it is easily accessible.

### macOS & Linux configuration

Throughout the documentation we refer to the CLI as `opschain`. For macOS and Linux users we suggest renaming the binary to reflect the common name (and save some future typing):

```bash
mv opschain-* opschain
```

macOS and Linux users will also need to make it executable:

```bash
chmod +x opschain
```

### Notes

- On macOS you may need to trust the OpsChain CLI binary as it is not currently signed. See [the Apple documentation](https://support.apple.com/en-au/guide/mac-help/mh40616/mac) for details
- The native binaries offer support for the latest version of the respective OS (older versions of the respective OS may work)

### Dev subcommand dependencies

The `opschain dev` subcommands depend on Docker. The `docker` executable must be available on the path and functional (i.e. `docker run --rm hello-world` should succeed) for these subcommands to be usable.

The open source [Docker Engine](https://docs.docker.com/engine/) package can be used on supported platforms. The open source upstream [Moby](https://mobyproject.org/) package can be used as an alternative on supported platforms. [Docker Desktop](https://www.docker.com/products/docker-desktop/) - or an alternative like [Rancher Desktop](https://rancherdesktop.io/), [Colima](https://github.com/abiosoft/colima), or [Multipass](https://multipass.run/docs/docker-tutorial) (among others) - can be used on platforms without native Docker/Moby support.

### Server subcommand dependencies

The OpsChain CLI `opschain server` subcommands depend on [Helm](https://helm.sh/docs/intro/install/) and [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl). These commands must be accessible on the PATH, and they must be configured to work with your target Kubernetes cluster.

## OpsChain CLI configuration

The OpsChain CLI uses an `.opschainrc` configuration file. If `.opschainrc` is present in the current working directory it is used, otherwise, the `.opschainrc` from the user's home directory is used.

An [example .opschainrc](/config_file_examples/opschainrc.example) is provided in this repository.

The configuration file supports INI or JSON (with comments) formats.

### CLI configuration locations

The OpsChain CLI configuration is loaded by the `rc` package. The [`rc` documentation](https://www.npmjs.com/package/rc#standards) specifies the locations where the configuration file can be placed - the `appname` is `opschain`.

_On Windows the `USERPROFILE` directory is used as the home directory._

### OpsChain CLI configuration settings

The `.opschainrc` file must be valid JSON and supports the following configuration:

| Configuration Key | Optional | Description                                                                                                                                                                                                                                                                                                                                                                                                              |
| :---------------- | :------- |:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `apiBaseUrl`      | no       | OpsChain API server URL                                                                                                                                                                                                                                                                                                                                                                                                  |
| `username`        | no       | OpsChain API username                                                                                                                                                                                                                                                                                                                                                                                                    |
| `password`        | no       | OpsChain API password                                                                                                                                                                                                                                                                                                                                                                                                    |
| `requestTimeout`  | yes      | modify the API request timeout (in milliseconds), increase this for slow servers/networks                                                                                                                                                                                                                                                                                                                                |
| `stepEmoji`       | yes      | show emoji for the step status, default `true` - set to `false` to display status as text                                                                                                                                                                                                                                                                                                                                |
| `projectCode`     | yes      | default OpsChain project code used for commands                                                                                                                                                                                                                                                                                                                                                                          |
| `environmentCode` | yes      | default OpsChain environment code used for commands                                                                                                                                                                                                                                                                                                                                                                      |
| `outputFormat`    | yes      | default OpsChain output format (if unset, the CLI will use the `table` format.<br><br>it can be set as a global default:<br>`"outputFormat": "json"`<br><br> or configured per operation:<br>`"outputFormat": {`<br>  `"create":"table",`<br>`"list":"json",`<br>`"show":"json"`<br>`}`<br><br>The following operations are supported for multi-format outputs: <ul><li>`create`</li><li>`list`</li><li>`show`</li></ul> |

### Environment variable configuration

OpsChain configuration can be overridden by using environment variables. This can be useful for temporarily overriding configuration.

Prefix the configuration key with `opschain_` and set as an environment variable to override the value from the `.opschainrc`.

```bash
export opschain_projectCode=dev
opschain environment ls # this will list environments in the dev project without prompting
```

## Timezones

The OpsChain CLI displays all timestamps in the timezone configured on the local machine. The exception to this are the timestamps included in the [step phase log messages](../reference/concepts/step_runner.md#log-messages-for-step-phases). These timestamps are generated by the OpsChain worker and step runner as the change is running and will be generated in the timezone these containers are configured in.

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

## Shell completion

The OpsChain CLI supports shell completion. To use it run the `opschain completion` subcommand, for example:

```bash
opschain completion >> ~/.zshrc # this assumes you are using Zsh, modify as needed
```

Then reload your shell, e.g. by running `exec zsh`. Now the CLI will support tab-completion for commands and arguments.

## OpsChain CLI container image

The OpsChain CLI is also distributed as a container image, `limepoint/opschain-cli:${OPSCHAIN_VERSION}`. The OPSCHAIN_VERSION used should match the server installation version - if unknown this can be seen via the `/info` API endpoint.

Some examples of how the CLI image can be used are shown below:

```bash
OPSCHAIN_VERSION="$(curl --user opschain:password 'http://localhost:3000/info' | jq -r .data.attributes.version)" # modify the API address and credentials as required, or enter the value manually if known
docker run -ti -v ~/.opschainrc:/.opschainrc limepoint/opschain-cli:${OPSCHAIN_VERSION} environment ls
# with files:
docker run -ti -v $(pwd):$(pwd) -v ~/.opschainrc:$(pwd)/.opschainrc -w $(pwd) limepoint/opschain-cli:${OPSCHAIN_VERSION} environment set-properties -f ./properties.json
```

### Using the OpsChain CLI in an OpsChain change

The OpsChain CLI container image also makes it simple to access the OpsChain CLI within a [custom step runner Dockerfile](concepts/step_runner.md#custom-step-runner-dockerfiles):

```dockerfile
ARG OPSCHAIN_VERSION
ARG OPSCHAIN_BASE_RUNNER
FROM limepoint/opschain-cli:${OPSCHAIN_VERSION} as cli
FROM ${OPSCHAIN_BASE_RUNNER}

...

COPY --from=cli /opschain /usr/bin/opschain
```

The CLI configuration can be included in the [environment variable properties](concepts/properties.md#environment-variables) using the [environment variable configuration](#environment-variable-configuration)

### Server management

The OpsChain CLI includes commands for configuring and managing OpsChain server instances. Learn more about the specific subcommands by running `opschain server --help`.

These commands create and manage the `.env` and `values.yaml` configuration files for an installation. For this reason we suggest creating a specific directory to store this configuration, and maintaining it as a Git repository if desired. All `opschain server` commands must then be run from this directory.

#### Supported platforms

The `opschain server` subcommands can be run on Linux, macOS and Windows.

On Windows, we suggest using a modern terminal like the [Windows Terminal from the Microsoft Store](https://aka.ms/terminal). The Powershell terminal and Command Prompt are also supported in a best-effort manner.

_We suggest avoiding Git Bash with the OpsChain CLI as it renders the prompts incorrectly._

#### Configuration overrides

The `opschain server deploy/start/stop` CLI commands will look for a `values.override.yaml` file in the current directory and will use it to override configuration in `values.yaml`.

This allows customisations to the `values.yaml` file to be stored and re-applied automatically, rather than needing to modify the `values.yaml` file after running the `opschain server configure` command.

The override file is provided to Helm and will override values in the main `values.yaml` using Helm's [values file](https://helm.sh/docs/chart_template_guide/values_files/) merging.

#### Full reconfiguration

When upgrading or reconfiguring an existing installation, the server configuration command will not re-ask questions whose answers cannot change.

If you would like to re-run the full server configuration remove/move the `.env` file (e.g. `mv .env .env.old`) and re-run `opschain server configure`.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
