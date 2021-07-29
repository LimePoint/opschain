# Getting Started

This guide takes you through installing and configuring your OpsChain environment and running a simple change.

After following this guide you should know how to:
- install, configure and start your OpsChain environment
- create an OpsChain user
- create some sample data
- list projects
- show project and environment properties
- find the action definitions for a project
- create a change
- view the logs of a running (or completed) change

## Prerequisites

### Required Software

#### Git

In order to clone the latest release of the OpsChain repository you will need a [Git](https://git-scm.com/) client.

#### OpenSSL

As part of configuring the environment, the [OpenSSL](https://www.openssl.org/) utility is called to generate various keys.

#### Docker Compose

You must have [Docker Compose](https://docs.docker.com/compose/install/) installed.

##### Docker Version

OpsChain supports the following Docker versions:
* macOS - Docker Desktop Community 3.1.0 and above.
* Linux - the latest Docker release.
* Windows Subsystem for Linux - the latest Docker release (installed in the WSL environment).

### Clone the OpsChain Release Repository

Clone the [OpsChain Release repository](https://github.com/LimePoint/opschain-release) to your local machine using your preferred Git client.

```bash
$ git clone https://github.com/LimePoint/opschain-release
$ cd opschain-release
```

### Configure Docker Hub access

You must be logged in to [Docker Hub](https://hub.docker.com/) as the `opschaintrial` user. _Contact [LimePoint](mailto:opschain@limepoint.com) to obtain the `opschaintrial` user credentials._

```bash
$ docker login --username opschaintrial
```

TIP: use the DOCKER_CONFIG environment variable if you need to use multiple Docker Hub logins.

```bash
$ export DOCKER_CONFIG="$(pwd)/.docker" # this would need to be exported in all opschain-release terminals
$ docker login --username opschaintrial
```

### Install MintPress Licence

OpsChain uses [MintPress Controllers](https://www.limepoint.com/mintpress) and for this you will require a licence (_contact [LimePoint](mailto:opschain@limepoint.com) to obtain a licence if you do not have one_).

Copy your licence file to the root of your cloned `opschain-release` working directory and ensure it is named `mintpress.licence`.

## Configure the OpsChain Environment

The environment utilises a [Docker Compose .env file](https://docs.docker.com/compose/compose-file/#env_file) to configure the running services.
You will only need to generate this file once (or if the available configuration options change).

To generate the `.env` file:

```bash
$ ./configure
```

You will be asked to confirm whether you would like to use certain features and will also be able to override default values for the location of database files and other settings.

_Note: On Windows Subsystem for Linux (WSL) you will need to enable full read-write-execute (777) permissions on the /var/run/docker.sock file_

### Pull Latest OpsChain Images

Pull the latest versions of the Docker images:
```bash
$ docker-compose pull
```

_Note: this may take a while on a slow connection._

### Start OpsChain Containers

Running containers in the foreground will allow you to see any log output directly on the console.

To start all containers in the foreground:

```bash
$ docker-compose up
```

This will start the OpsChain server and its dependent services in separate Docker containers.  For more information on these containers see the [Architecture Overview](reference/architecture.md).

_Note: Use a new terminal to run any CLI commands below._

### Add the OpsChain Commands to the Path

To add the OpsChain commands to the path run:

```bash
$ export PATH="$(pwd)/bin:$PATH" # set the path for the current shell
```

To make the change permanent the path can be modified in your shell config file, eg:

```bash
$ echo export PATH=\"$(pwd)/bin:'$PATH'\" >> ~/.zshrc # or ~/.bashrc if using bash
$ exec zsh # reload the shell config by starting a new session (replace zsh with bash as appropriate)
```

Alternatively, the OpsChain commands can be run without adding them to the path by specifying the full path to the command each time. The examples below assume the commands have been added to the path.

_The OpsChain commands do not support being executed via symlinks (ie `ln -s opschain /usr/bin/opschain` will not work)._

### Create an OpsChain User

The OpsChain API server requires a valid username and password. To create a user, execute:

```bash
$ opschain-utils "create_user['opschain','password']"
```
### Create an OpsChain CLI Configuration File

Copy the example CLI configuration file to your home directory:

```bash
$ cp .opschainrc.example ~/.opschainrc
```

Verify the username and password combination created earlier is reflected in the configuration file.

```bash
$ cat ~/.opschainrc
```

If you changed the username or password in the create_user command above, please edit the `.opschainrc` file to reflect your changes.

_Note: If you create a `.opschainrc` file in your current directory, this will be used in precedence to the version in your home directory._

### Create Sample Data

Sample [projects](reference/concepts.md#project) and [environments](reference/concepts.md#environment) can be created in the OpsChain database:

```bash
$ opschain-utils create_sample_data
```

The command will also create a sample commit in each project's [Git repository](reference/concepts.md#project-git-repository) containing the OpsChain [actions](reference/concepts.md#action) that will be run below (the actions implement a simple "hello world" example).

## Using the OpsChain Client CLI

The OpsChain client CLI can be used to interact with an OpsChain server instance. In these examples the server is running on your local machine but in most installations will be installed in a central location and shared.

### Check Available CLI Commands

Running the OpsChain CLI without any parameters will provide a list of available commands:

```bash
$ opschain
```

Adding one of these commands to the CLI will display the sub-commands that apply to it:

```bash
$ opschain environment
```

More information about each sub-command is available by appending the `--help` option

```bash
$ opschain environment create --help
```

Any sub-command arguments not supplied via options will be prompted for.

Any create sub-command will also require confirmation.

Output will be displayed in tabular format.

_Note that the `opschain` command uses the config in `.opschainrc` and the `./cli-files` directory relative to where the command is executed. Hence, we suggest always using `opschain` from the `opschain-release` directory - or you could copy the `.opschainrc` config file and the `cli-files` directory somewhere else._

### List Available Projects

Use the project list command to show available projects.

```bash
$ opschain project list
```

Manually copy and set the project ID related to the _Payables Team_ project as an environment variable, you'll need it for the next steps:

```bash
$ project_id=XXXXX
```

### Querying Properties

The sample projects and environments created earlier include sample [properties](reference/properties.md). The OpsChain CLI enables you to view the current properties values.

```bash
$ opschain project properties-show --project_id $project_id
$ opschain environment properties-show --project_id $project_id --environment_code dev_p
```

### Project Git Repository

Each OpsChain project is linked to a local Git repository (by default located at `./opschain_project_git_repos/production/$project_id`). Commits in the repository are the [Git references](https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection) that refer to the state of configuration at a given version.

You can use Git commands such as [branch](https://git-scm.com/docs/git-branch) and [tag](https://git-scm.com/docs/git-tag) to find references that you can use in order to refer to a specific commit ref.

A deployable commit must include the `actions.rb` entrypoint.  This file defines the [actions](reference/concepts.md#action) available to be performed as part of an OpsChain change.

You can interact and make changes directly to the local Git repository, or link the repository to a [remote](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes) as shown in the [Confluent Example](running_a_complex_change.md).

#### View the Project's actions.rb

The _Payables Team_ project's `actions.rb` file can be viewed to see how the example [actions](reference/concepts.md#action) are constructed:

```bash
$ cat "./opschain_project_git_repos/production/$project_id/actions.rb"
```

See the [Actions Reference Guide](reference/actions.md) and the [Developing Your Own Resources](developing_resources.md) guide for further information about the `actions.rb` file structure and contents.

### Create a Change

Create a change to run the `default` action, from the latest commit in the _Payables Team_ Git repository, in the _Payables Team_'s Development environment:

```bash
$ opschain change create --project_id $project_id --environment_code dev_p --commit_ref HEAD --action default --confirm
```

The [steps](reference/concepts.md#step) that comprise the change will be shown as well as their status.

Manually copy and set the change ID as a variable, you'll need it for the next steps:

```bash
$ change_id=XXXXX
```

### Display Change Status

The information displayed in the table after submitting a [change](reference/concepts.md#change) can be displayed at any time by running the `change show` command.

```bash
$ opschain change show --change_id $change_id
```

### Review the Change Logs

Review the output produced by the [steps](reference/concepts.md#step) in your [change](reference/concepts.md#change).

```bash
$ opschain change logs-show --change_id $change_id
```

## What to Do Next

### See Properties Override In Action

Note that the `Payables Team` [project](reference/concepts.md#project) and `dev_p` [environment](reference/concepts.md#environment) include values for `test/some_property` and the `sit_p` environment does not.  Compare the [properties](reference/properties.md) displayed in the [change](reference/concepts.md#change) logs when the [change](reference/concepts.md#change) is executed against these two [environments](reference/concepts.md#environment).

```bash
$ opschain change create --project_id $project_id --environment_code dev_p --commit_ref master --action default --confirm
$ opschain change create --project_id $project_id --environment_code sit_p --commit_ref master --action default --confirm
```

### Change Some Properties

Follow the [Loading Properties](reference/properties.md#loading-properties) guide to try editing some [project](reference/concepts.md#project) or [environment](reference/concepts.md#environment) properties.

### Try a More Advanced Example

The [Confluent Example](running_a_complex_change.md) documentation provides an example of using OpsChain to build and deploy a confluent control-centre, zookeeper and brokers (as Docker containers).

### Try Developing Your Own Resources

The [Developing Your Own Resources](developing_resources.md) guide explains the structure of the `actions.rb` file, along with the keywords available to build your resource types, resources and actions.

### Review the Reference Documentation

The [Reference Documentation](reference/index.md) provides in-depth descriptions of many of the features available in OpsChain.

# Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
