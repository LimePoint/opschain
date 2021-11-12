# OpsChain installation guide

This guide takes you through installing and configuring OpsChain.

After following this guide you should know how to:

- install OpsChain pre-requisites
- configure Docker Hub access
- install, configure and start OpsChain
- create an OpsChain user
- download a native OpsChain CLI (optional)

## Prerequisites

### Required software

#### Git

In order to clone the latest release of the OpsChain repository you will need a [Git](https://git-scm.com/) client.

#### OpenSSL

As part of configuring the environment, the [OpenSSL](https://www.openssl.org/) utility is called to generate various keys.

#### Docker Compose

You must have [Docker Compose](https://docs.docker.com/compose/install/) installed.

_Note: [Compose V2](https://docs.docker.com/compose/cli-command/) is not supported during the OpsChain trial._

The Docker service/daemon must be running.

##### Docker version

OpsChain supports the following Docker versions:

- macOS - Docker Desktop Community 3.1.0 and above
- Linux - the latest Docker release
- Windows Subsystem for Linux (WSL) - the latest Docker release (installed in the WSL environment). Note:
  - _Prior to running the OpsChain Docker containers in WSL, we recommend adjusting the "memory" setting in your [WSL 2 Settings](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#wsl-2-settings). The default setting can cause WSL to consume most of the machine's memory when running Docker containers in WSL._
  - _For a better CLI experience we suggest using a modern terminal (like the [Windows Terminal from the Microsoft Store](https://aka.ms/terminal) or a WSL terminal)._

### Clone the OpsChain trial repository

Clone the [OpsChain trial repository](https://github.com/LimePoint/opschain-trial) to your local machine using your preferred Git client.

```bash
git clone git@github.com:LimePoint/opschain-trial.git
cd opschain-trial
```

### Install the OpsChain licence

Copy the `opschain.lic` licence file into the current folder (`opschain-trial`).

### Configure Docker Hub access

You must be logged in to [Docker Hub](https://hub.docker.com/) as the `opschaintrial` user (or, if you have an [enterprise licence for OpsChain](../reference/opschain_and_mintpress.md#enterprise-controllers-for-oracle), the `opschainenterprise` user). _Contact [LimePoint](mailto:opschain@limepoint.com) to obtain the user credentials._

```bash
docker login --username opschaintrial
```

TIP: use the DOCKER_CONFIG environment variable if you need to use multiple Docker Hub logins.

```bash
export DOCKER_CONFIG="$(pwd)/.docker" # this would need to be exported in all opschain-trial terminals
docker login --username opschaintrial
```

### Create a GitHub personal access token

A variety of OpsChain Git repositories have been created to provide sample code for the getting started guide, and examples of how you might implement different types of changes. To access these repositories you will need to create a [GitHub personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token). Do this now to allow you to follow the getting started guide and access the more advanced examples.

## Configure the OpsChain environment

OpsChain needs to be configured before first run (and when upgrading) by executing the configuration script:

```bash
./configure
```

You will be asked to confirm whether you would like to use certain features and will also be able to override default values for the location of database files and other settings.

_Note: On Windows Subsystem for Linux (WSL) you will need to enable full read-write-execute (777) permissions on the /var/run/docker.sock file._

### Pull latest OpsChain images

Pull the latest versions of the Docker images:

```bash
docker-compose pull
```

_Note: this may take a while on a slow connection._

### Start OpsChain containers

Running containers in the foreground will allow you to see any log output directly on the console.

To start all containers in the foreground:

```bash
docker-compose up
```

This will start the OpsChain server and its dependent services in separate Docker containers. For more information on these containers see the [architecture overview](../reference/architecture.md).

When the OpsChain banner message has been displayed, the server is ready and you can proceed to the next steps of this guide.

_Note: Use a new terminal to run any CLI commands below._

### Add the OpsChain commands to the path

To add the OpsChain commands to the path run:

```bash
export PATH="$(pwd)/bin:$PATH" # set the path for the current shell
```

To make the change permanent the path can be modified in your shell config file, e.g.:

```bash
echo export PATH=\"$(pwd)/bin:'$PATH'\" >> ~/.zshrc # or ~/.bashrc if using bash
exec zsh # reload the shell config by starting a new session (replace zsh with bash as appropriate)
```

Alternatively, the OpsChain commands can be run without adding them to the path by specifying the full path to the command each time. The examples below assume the commands have been added to the path.

_The OpsChain commands do not support being executed via symlinks (i.e. `ln -s opschain /usr/bin/opschain` will not work)._

### Create an OpsChain user

The OpsChain API server requires a valid username and password. To create a user, execute:

```bash
opschain-utils "create_user['opschain','password']"
```

_Note: Please ensure there are no spaces included in the parameter you supply to `opschain_utils`._

### Create an OpsChain CLI configuration file

Copy the example CLI configuration file to your home directory:

```bash
cp .opschainrc.example ~/.opschainrc
```

Verify that the username and password combination created earlier is reflected in the configuration file.

```bash
cat ~/.opschainrc
```

If you changed the username or password in the create_user command above, please edit the `.opschainrc` file to reflect your changes.

Learn more about the `opschainrc` configuration in the [CLI configuration guide](../reference/cli.md#opschain-cli-configuration).

_Note: If you create a `.opschainrc` file in your current directory, this will be used in precedence to the version in your home directory._

#### Download the native CLI (optional)

OpsChain has native CLI binaries for Windows, macOS and Linux. The native CLI has better performance than the CLI bundled in the `opschain-trial` repository, as well as native filesystem access.

Once downloaded, the native CLI will need to be added to the path or used directly. In addition, the `apiBaseUrl` configuration in `~/.opschainrc` must be updated to reflect the external OpsChain API address. This address reflects the OpsChain listening port specified as part of the `./configure` script. If you accepted the default setting, this will be `http://localhost:3000/`.

[Read our documentation about downloading the native CLI.](../reference/cli.md#opschain-native-cli)

## What to do next

- (optional) OpsChain is supplied with an LDAP server for authentication. If you'd prefer to use your own LDAP server, follow the [OpsChain LDAP](../operations/opschain_ldap.md) guide to alter the OpsChain authentication configuration.
- Return to the [getting started guide](README.md) to learn more about OpsChain.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
