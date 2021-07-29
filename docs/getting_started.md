# Getting Started

This guide takes you through installing and configuring your OpsChain environment and running a simple change.

After following this guide you should know how to:
- install, configure and start your OpsChain environment
- create an OpsChain user
- create some sample data
- list projects
- list actions in an OpsChain project
- interactively run an action in an OpsChain project
- create a change
- view the logs of a running (or completed) change
- view the history of changes in an environment

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

_Note: On Windows Subsystem for Linux (WSL) you will need to enable full read-write-execute (777) permissions on the /var/run/docker.sock file._

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

This will start the OpsChain server and its dependent services in separate Docker containers. For more information on these containers see the [Architecture Overview](reference/architecture.md).

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

Create a sample [project](reference/concepts.md#project) and [environment](reference/concepts.md#environment) in the OpsChain database:

```bash
$ opschain-utils create_sample_data
```

This command will also create a sample commit in the project's [Git repository](reference/concepts.md#project-git-repository) containing the OpsChain [action](reference/concepts.md#action) that will be run below (the action implements a simple "hello world" example).

#### Listing Available Projects

Run the OpsChain project list command to see the newly created project:

```bash
$ opschain project list
```

## Running OpsChain Actions

OpsChain is a tool for running actions. OpsChain actions can be developed interactively by using the `opschain-action` and `opschain-dev` utilities.

### Running an Action Locally

You can use the `opschain-action` utility to list the actions available within the current project.

Enter the project's Git repository working directory (this is required to use the `opschain-action` command):

```bash
$ cd opschain_data/opschain_project_git_repos/demo
```

_Note: The path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._

You can now list the actions available in this project by running the following command:

```bash
$ opschain-action -T # this will list all actions with a description (or use -AT to show all configured actions)
```

Running the `create_sample_data` command earlier created an actions.rb file in this project that contains a single action, `hello_world`.

You can run this action locally by using the `opschain-action` command as follows:

```bash
$ opschain-action hello_world
Hello World
```

### Adding a New Action (optional)

Open the `actions.rb` file with your favourite editor so that you can add the new action to the project.

Add the following to the bottom of the file (after the `hello_world` action):

```ruby
desc 'Say Goodbye World' # if this line were omitted then this action would not be shown in `opschain-action -T`
action :goodbye_world do
  puts 'Goodbye World' # you could write any Ruby in here, but OpsChain provides a friendlier API in addition to this
end
```

You can now manually run the new `goodbye_world` task in addition to the existing `hello_world` task:

```bash
$ opschain-action hello_world goodbye_world
Hello World
Goodbye World
```

Add the following to the `actions.rb` file to configure the project to run both of these actions as the default action (eg when you don't specify which action to run):

```ruby
action default: [ :hello_world, :goodbye_world ]
```

You can now run the default action:

```bash
$ opschain-action
Hello World
Goodbye World
```

Commit the changes to the `actions.rb` file to allow them to be used via the OpsChain server:

```bash
$ git add actions.rb
$ git commit -m "Add a Goodbye action and run hello_world and goodbye_world by default."
```

See the [Actions Reference Guide](reference/actions.md) and the [Developing Your Own Resources](developing_resources.md) guide for further information about the `actions.rb` file structure and contents.

### Return to the OpsChain Release Directory

Return to the `opschain-release` repository directory to continue following this guide:

```bash
$ cd ../../..
```

## Creating an OpsChain Change

You can use the OpsChain CLI to create a new [change](reference/concepts.md#change). A change runs an action (which may have dependent actions or steps) on the OpsChain server.

The OpsChain CLI (`opschain`) can be used to interact with an OpsChain server instance. In these examples the server is running on your local machine but in most installations will be installed in a central location and shared.

### Running the Hello World Action via a Change

You can use the `opschain change create` command to run the sample `hello_world` action as follows:

```bash
# the `hello_world` can be changed to `default` (or even `''`) if you followed the `Adding a New Action` steps
$ opschain change create --project-code demo --environment-code dev --commit-ref HEAD --action hello_world --confirm
```

This will run the change using an OpsChain runner which has been started and managed by an OpsChain worker - a part of the OpsChain server.

This command will show you an overview of the action as it executes. It will not show the `hello_world` task output because it has been sent to the OpsChain log aggregator.

To see the output you can use the `opschain change logs-show` command as follows:

```bash
$ opschain change logs-show --change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx # replace with the ID from the `change create` output
```

If you ever need to revisit the status of a change you can use the change list and change show commands:

```bash
$ opschain change list --project-code demo --environment-code dev # if you need to find out about other changes
$ opschain change show --change-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx # replace with the ID from the `change list` output
```

## What to Do Next

### Learn More About OpsChain Actions

Follow the [Actions Reference Guide](reference/actions.md) and add more advanced actions to the sample [project](reference/concepts.md#project).

### Learn More About OpsChain Properties

Follow the [Loading Properties](reference/properties.md#loading-properties) guide to try editing some [project](reference/concepts.md#project) or [environment](reference/concepts.md#environment) properties.

### Try a More Advanced Example

- The [Terraform Example](running_a_simple_terraform_change.md) demonstrates how to use OpsChain with Terraform to build a simple nginx Docker container.

- The [Ansible Example](running_an_aws_ansible_change.md) demonstrates how to use OpsChain with Terraform, Ansible and AWS to build and configure a simple nginx instance on AWS.

- The [Confluent Example](running_a_complex_change.md) demonstrates how to use OpsChain to build and deploy a confluent control-centre, zookeeper and brokers (as Docker containers).

### Try Developing Your Own Resources

The [Developing Your Own Resources](developing_resources.md) guide explains the structure of the `actions.rb` file, along with the keywords available to build your resource types, resources and actions.

### Review the Reference Documentation

The [Reference Documentation](reference/index.md) provides in-depth descriptions of many of the features available in OpsChain.

## Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
