# Running a Complex Change

Run a more complex change that builds a multi-node [Confluent](https://www.confluent.io/) setup on your local Docker installation.

After following this guide you should know how to:
- create a project and environment
- add a remote Git repository as a project remote
- set/view properties on the environment
- view the properties used during a change
- understand how to provide a custom Dockerfile

### Create a Project

Create a new project:

```bash
$ opschain project create --code confluent --name 'Demo Confluent Project' --description 'My Confluent project' --confirm
```

Verify that your new project appears in the list:

```bash
$ opschain project list
```

### Create an Environment

Environments represent the logical infrastructure environments under a project (for example Development or Production).

Create a new environment:

```bash
$ opschain environment create --project-code confluent --code local --name 'Confluent Environment' --description 'My Confluent environment' --confirm
```

Verify that your new environment appears in the list:

```bash
$ opschain environment list --project-code confluent
```

### Add the Confluent Example as a Remote to the Project Git Repository

Follow [Adding a Project Git Repository as a Remote](reference/project_git_repositories.md#adding-a-project-git-repository-as-a-remote) using the OpsChain Confluent Example repository remote URL `https://username:password@github.com/LimePoint/opschain-examples-confluent.git`.

### Fetch the Latest Confluent Example Code

Navigate to the project's Git repository and fetch the latest code.

_Note: Ensure you return to the opschain-release directory before running further commands._
```bash
$ cd opschain_data/opschain_project_git_repos/confluent
$ git fetch
$ git checkout master
$ cd ../../..
```

_Note: The confluent path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._

### OpsChain Properties

This example takes advantage of the [OpsChain Properties](reference/properties.md) feature of OpsChain to provide the configuration for the various Confluent servers. The `.opschain/properties.json` file in the Git repository provides the bulk of the configuration information. In addition, an example environment properties file is provided to highlight overriding the project repository defaults with specific values.

#### Import the Environment Properties

Properties can be loaded from a local file containing a valid JSON object. To make the file available to the opschain-cli container, copy the file into the opschain-release `cli-files` directory. A sample Environment Properties file is included in the Confluent repository.

To load the file, perform the following steps:
1. Copy the sample file into the opschain-cli temporary directory as follows:

```bash
$ cp opschain_data/opschain_project_git_repos/confluent/environment_properties.json ./cli-files
```

_Note: The path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._

2. Set the environment specific [properties](reference/properties.md) using the following command:

```bash
$ opschain environment properties-set --project-code confluent --environment-code local --file-path cli-files/environment_properties.json --confirm
```

These environment [properties](reference/properties.md) will:

- override values from the project [properties](reference/properties.md)
  - `auto.create.topics.enable` - set to false
  - `log.retention.check.interval.ms` - set to 301

#### Setting Properties Dynamically

The `actions.rb` provided in the Confluent repository includes logic to set environment specific [properties](reference/properties.md) as part of the provision action:
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

- override a Confluent broker default value:
  - `num.network.threads` - set to 5 (default is 3)

- override the project level property:
  - `log.retention.check.interval.ms` - set to 1234876

Note: project or environment [properties](reference/properties.md) set dynamically in the [action](reference/concepts.md#action) will only be updated against the project or environment if the [action](reference/concepts.md#action) completes successfully (i.e. if a [step](reference/concepts.md#step) has an error, the [properties](reference/properties.md) are not updated).

### Create a Change

Create a new change for the current `origin/master` branch of your project and run the `default` action:

```bash
$ opschain change create --project-code confluent --environment-code local --commit-ref origin/master --action default --confirm
```

The [steps](reference/concepts.md#step) that comprise the change will be shown as well as their status.

_Note: the first step in this change may take a long time as it downloads a Centos Docker image as well as installation executables for Java and Confluent. Subsequent runs will use Docker's  layer caching feature and should not require these to be re-downloaded._

Manually copy and set the change ID as a variable, you'll need it for the next steps:

```bash
$ change_id=XXXXX
```

**Use the `opschain change logs-show` command to see the log output from the change (including any failures).**

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
$ opschain change properties-show --change-id $change_id
```

More detailed information about the specific versions of environment and project [properties](reference/properties.md) supplied to each [step](reference/concepts.md#step) of the change is available directly from the API server. Using your browser, navigate to http://localhost:3000/changes/CHANGE_ID _(where CHANGE_ID is the ID of the change)_. In the API response, each [step](reference/concepts.md#step) has a reference to the project and environment [properties](reference/properties.md) versions supplied to the [step](reference/concepts.md#step).

## Notes on the Confluent Example

### Repository Dockerfiles

The repository includes two Dockerfiles

1. The `Dockerfile` in `.opschain` builds a custom OpsChain Step Runner image that includes
    - The Terraform binary required for the `terraform_config` resource type
    - The JRE Installer required for the Confluent containers
    - The Confluent Installer required for the Confluent containers

2. The `Dockerfile` in the repository root is based off a Centos image and defines the image that is used as the basis for the Confluent containers. This image is built as part of the `provision` action, copying the installers from the custom Step Runner and installing the dynamically generated SSH keys.

### OpsChain Runner Network

The terraform `main.tf` file specifies the control center, broker and zookeeper containers should be started on the `opschain-runner-network`. This is the same network as the OpsChain Step Runner containers and allows the Confluent containers to be referred to via their alias (eg broker1).

### External Packages

The example makes use of the following packages
- the [Terraform Docker Provider](https://www.terraform.io/docs/providers/docker)
- the [MintPress](https://www.limepoint.com/mintpress) Confluent controller.

## What to Do Next

### Create Your Own Project

Try creating a new project using the steps above and instead of adding a remote, author your own commits. See the [Reference Documentation](reference/index.md) and [Developing Your Own Resources](developing_resources.md) guide for more information.

# Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
