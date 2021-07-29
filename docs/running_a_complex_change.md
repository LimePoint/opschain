# Running a Complex Change

Run a more complex change that builds a multi-node [Confluent](https://www.confluent.io/) setup on your local Docker installation.

After following this guide you should know how to:
- create a project and environment
- add a remote Git repository as a project remote
- set/view properties on the project and environment
- view the properties used during a change
- understand how to provide a custom Dockerfile

### Create a Project

Create a new project:

```bash
$ opschain project create --name 'Demo Project' --description 'My demo project' --confirm
```

Verify that your new project appears in the list:

```bash
$ opschain project list
```

Manually copy and set the project ID as a variable, you'll need it for the next steps:

```bash
$ project_id=XXXXX
```

### Create an Environment

Environments represent the logical infrastructure environments under a project (for example Development or Production).

Create a new environment:

```bash
$ opschain environment create --project_id $project_id --code local --name 'Local Environment' --description 'My Local Environment' --confirm
```

Verify that your new environment appears in the list:

```bash
$ opschain environment list --project_id $project_id
```

Set the environment code as a variable, you'll need it for the next steps:

```bash
$ environment_code=local
```

### Add the Confluent Example as a Remote to the Project Git Repository

#### Create a Github Personal Access Token

If you choose to use your Github username and password when connecting the example repository, you will see warnings displayed whenever OpsChain accesses the repository. Alternatively, follow the Github guide to create a [Github personal access token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token).

#### Set the Project Git Remote

Add the OpsChain Confluent example Git repository as a [remote](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes):

```bash
# Note: to avoid potentially storing the repository credentials in the shell history the `--url` argument can be omitted and filled in when prompted
$ opschain project git-remote-set -p $project_id --name origin --url "https://{username}:{password / personal access token}@github.com/LimePoint/opschain-examples-confluent.git"
```

#### Project Git Repository Remote Credentials

To be used by OpsChain, the remote must be either:
- An unauthenticated Git remote.
- A http(s) authenticated Git remote where the username and password are embedded in the remote URL. For example `https://username:password@github.com/LimePoint/opschain-examples-confluent`.

OpsChain does not support any other authentication mechanisms for Git remotes.

_Using SSH keys for authentication is not supported however some users have reported success with this [unsupported workaround](troubleshooting.md#git-remotes-with-ssh-authentication)._

### Fetch the Latest Confluent Example Code

Navigate to the project's Git repository and fetch the latest code.

_Note: Ensure you to return to the opschain-release directory before running further commands._
```bash
$ cd opschain_project_git_repos/production/$project_id
$ git fetch
$ git checkout master
$ cd ../../..
```

### OpsChain Properties
#### Import the Confluent Example Properties

Properties can be loaded from a local file containing a valid JSON object. To make the file available to the opschain-cli container, copy the file into the opschain-release `cli-files` directory. Sample Project and Environment Properties files are included in the confluent repository.

To load the files, perform the following steps:
1. Copy the sample files into the opschain-cli temporary directory as follows:

```bash
$ cp opschain_project_git_repos/production/"$project_id"/*properties.json ./cli-files
```
2. Set the project specific [properties](reference/properties.md) using the following command:

```bash
$ opschain project properties-set --project_id $project_id --file_path cli-files/project_properties.json --confirm
```

These project [properties](reference/properties.md) will provide the common properties to configure the various hosts and confluent products.

3. Set the environment specific [properties](reference/properties.md) using the following command:

```bash
$ opschain environment properties-set --project_id $project_id --environment_code $environment_code --file_path cli-files/environment_properties.json --confirm
```

These environment [properties](reference/properties.md) will:

- override values from the project [properties](reference/properties.md)
  - `auto.create.topics.enable` - set to false
  - `log.retention.check.interval.ms` - set to 301
- set the `TF_IN_AUTOMATION` Terraform environment variable to instruct Terraform that it is running in non-human interactive mode.

#### Setting Properties Dynamically

The `actions.rb` provided in the confluent repository includes logic to set environment specific [properties](reference/properties.md) as part of the provision action:
```
action provision: ['build_confluent_docker_base', 'terraform:apply'] do
  OpsChain.environment.properties.brokers =
    {
      broker1: {
        properties: {
          "log.retention.check.interval.ms": '1234876',
          "num.network.threads": 5
        }
      }
    }
    ...
```
This set of properties will:

- override a confluent broker default value:
  - `num.network.threads` - set to 5 (default is 3)

- override the project level property:
  - `log.retention.check.interval.ms` - set to 1234876

Note: project or environment [properties](reference/properties.md) set dynamically in the [action](reference/concepts.md#action) will only be updated against the project or environment if the [action](reference/concepts.md#action) completes successfully (i.e. if a [step](reference/concepts.md#step) has an error, the [properties](reference/properties.md) are not updated).

### Create a Change

Create a new change for the current `origin/master` branch of your project and run the `default` action:

```bash
$ opschain change create --project_id $project_id --environment_code local --commit_ref origin/master --action default --confirm
```

_Note: the first step in this change may take a long time as it downloads a Centos Docker image as well as installation executables for Java and Confluent. Subsequent runs will use Docker's  layer caching feature and should not require these to be re-downloaded._

Manually copy and set the change ID as a variable, you'll need it for the next steps:

```bash
$ change_id=XXXXX
```

**Refer to the terminal running the server to see the details of the change (including any failures).**

The [steps](reference/concepts.md#step) that comprise the change will be shown as well as their status.

### Verify Change Deployment

#### Check Running Servers

Use Docker to check that you have two **brokers**, a **zookeeper** and a **control-center** running:

```bash
$ docker ps -f name=zookeeper\|broker\|control-center
```

#### Check Control Center Settings

Navigate to the _controlcenter.cluster, Cluster Settings, Brokers_  page in your [locally running control center](http://localhost:9021) to see the overridden log retention check interval ms.

#### Produce/Consume a Message via Kafka

First start a consumer on the control center:

```bash
$ docker exec -it control-center bash
[root@consumer /] export JAVA_HOME=/apps/confluent-demo/binaries/java/
[root@consumer /] /apps/confluent-demo/binaries/kafka/bin/kafka-console-consumer --bootstrap-server broker1:9092 --topic demo --from-beginning --group cli-1
```

Then in a new terminal, produce a message:

```bash
$ docker exec -it control-center bash
[root@producer /] export JAVA_HOME=/apps/confluent-demo/binaries/java/
[root@producer /] /apps/confluent-demo/binaries/kafka/bin/kafka-console-producer --broker-list broker1:9092 --topic demo
> hello there
```

Verify that the message then appears in the consumer terminal:

```
[root@consumer /] /apps/confluent-demo/binaries/kafka/bin/kafka-console-consumer --bootstrap-server broker1:9092 --topic demo --from-beginning --group cli-1
hello there
```

### Viewing Properties Used By The Change

It can be useful for troubleshooting to know which [properties](reference/properties.md) were used by a change when it ran (whether the change was successful or had an error). You can view the merged set of [properties](reference/properties.md) that the change started with:

```bash
$ opschain change properties-show --change_id $change_id
```

More detailed information about the specific versions of environment and project [properties](reference/properties.md) supplied to each [step](reference/concepts.md#step) of the change is available directly from the API server. Using your browser, navigate to http://localhost:3000/changes/CHANGE_ID _(where CHANGE_ID is the ID of the change)_. In the API response, each [step](reference/concepts.md#step) has a reference to the project and environment [properties](reference/properties.md) versions supplied to the [step](reference/concepts.md#step).

## Notes on the Confluent Example

### Repository Dockerfiles

The repository includes two Dockerfiles

1. The `Dockerfile` in `.opschain` builds a custom OpsChain Step Runner image that includes
    - The Terraform binary required for the `terraform_config` resource_type
    - The JRE Installer required for the Confluent containers
    - The Confluent Installer required for the Confluent containers

2. The `Dockerfile` in the repository root is based off a Centos image and defines the image that is used as the basis for the Confluent containers. This image is built as part of the `provision` action, copying the installers from the custom Step Runner and installing the dynamically generated SSH keys.

### OpsChain Runner Network

The terraform `main.tf` file specifies the control center, broker and zookeeper containers should be started on the `opschain-runner-network`.  This is the same network as the OpsChain Step Runner containers and allows the Confluent containers to be referred to via their alias (eg broker1).

### External Packages

The example makes use of the following packages
- the [Terraform Docker Provider](https://www.terraform.io/docs/providers/docker)
- the [MintPress](https://www.limepoint.com/mintpress) Confluent controller.

## What to Do Next

### Create Your Own Project

Try creating a new project using the steps above and instead of adding a remote, author your own commits.  See the [Reference Documentation](reference/index.md) and [Developing Your Own Resources](developing_resources.md) guide for more information.

# Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
