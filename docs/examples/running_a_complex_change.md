# Running a complex change

Run a more complex change that builds a multi-node [Confluent](https://www.confluent.io/) setup on your local Docker installation.

After following this guide you should know how to:

- create a project and environment
- add a remote Git repository as a project remote
- set/view properties on the environment
- view the properties used during a change
- understand how to provide a custom Dockerfile

## Create a project

Create a new project:

```bash
opschain project create --code confluent --name 'Demo Confluent Project' --description 'My Confluent project' --confirm
```

Verify that your new project appears in the list:

```bash
opschain project list
```

## Create an environment

Environments represent the logical infrastructure environments under a project (for example Development or Production).

Create a new environment:

```bash
opschain environment create --project-code confluent --code local --name 'Confluent Environment' --description 'My Confluent environment' --confirm
```

Verify that your new environment appears in the list:

```bash
opschain environment list --project-code confluent
```

## Add the Confluent example as a remote to the project Git repository

Follow [adding a project Git repository as a remote](../reference/project_git_repositories.md#adding-a-project-git-repository-as-a-remote) using the [OpsChain Confluent Example repository](https://github.com/LimePoint/opschain-examples-confluent) remote URL `https://username:password@github.com/LimePoint/opschain-examples-confluent.git`.

## Fetch the latest Confluent example code

Navigate to the project's Git repository and fetch the latest code.

_Note: Ensure you return to the opschain-trial directory before running further commands._

```bash
cd opschain_data/opschain_project_git_repos/confluent
git fetch
git checkout master
cd ../../..
```

_Note: The confluent path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._

## OpsChain properties

This example takes advantage of the [OpsChain properties](../reference/concepts/properties.md) feature of OpsChain to provide the configuration for the various Confluent servers. The `.opschain/properties.json` file in the Git repository provides the bulk of the configuration information. In addition, an example environment properties file is provided to highlight overriding the project repository defaults with specific values.

### Import the environment properties

Properties can be loaded from a local file containing a valid JSON object. To make the file available to the opschain-cli container, copy the file into the opschain-trial `cli-files` directory. A sample environment properties file is included in the Confluent repository.

To load the file, perform the following steps:

1. Copy the sample file into the opschain-cli temporary directory as follows:

    ```bash
    cp opschain_data/opschain_project_git_repos/confluent/environment_properties.json ./cli-files
    ```

    _Note: The path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._

2. Set the environment specific [properties](../reference/concepts/properties.md) using the following command:

    ```bash
    opschain environment set-properties --project-code confluent --environment-code local --file-path cli-files/environment_properties.json --confirm
    ```

    These environment [properties](../reference/concepts/properties.md) will:

    - override values from the project [properties](../reference/concepts/properties.md)
      - `auto.create.topics.enable` - set to false
      - `log.retention.check.interval.ms` - set to 301

### Setting properties dynamically

The `actions.rb` provided in the Confluent repository includes logic to set environment specific [properties](../reference/concepts/properties.md) as part of the provision action:

```ruby
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

Note: project or environment [properties](../reference/concepts/properties.md) set dynamically in the [action](../reference/concepts/concepts.md#action) will only be updated against the project or environment if the [action](../reference/concepts/concepts.md#action) completes successfully (i.e. if a [step](../reference/concepts/concepts.md#step) has an error, the [properties](../reference/concepts/properties.md) are not updated).

## Create a change

Create a new change for the current `origin/master` branch of your project and run the `default` action:

```bash
opschain change create --project-code confluent --environment-code local --git-rev origin/master --action default --confirm
```

The [steps](../reference/concepts/concepts.md#step) that comprise the change will be shown as well as their status.

_Note: the first step in this change may take a long time as it downloads a Centos Docker image as well as installation executables for Java and Confluent. Subsequent runs will use Docker's  layer caching feature and should not require these to be re-downloaded._

Manually copy and set the change ID as a variable, you'll need it for the next steps:

```bash
change_id=XXXXX
```

**Use the `opschain change show-logs` command to see the log output from the change (including any failures).**

## Verify change deployment

### Check running servers

Use Docker to check that you have two **brokers**, a **zookeeper** and a **control-center** running:

```bash
docker ps -f name=zookeeper\|broker\|control-center
```

### Check control center settings

Navigate to the _controlcenter.cluster, Cluster Settings, Brokers_  page in your [locally running control center](http://localhost:9021) to see the overridden log retention check interval ms.

### Produce/consume a message via Kafka

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

```bash
[root@consumer /] /apps/confluent-demo/binaries/kafka/bin/kafka-console-consumer --bootstrap-server broker1:9092 --topic demo --from-beginning --group cli-1
hello there
```

## Viewing properties used by the change

It can be useful for troubleshooting to know which [properties](../reference/concepts/properties.md) were used by a change when it ran (whether the change was successful or had an error). You can view the merged set of [properties](../reference/concepts/properties.md) that the change started with:

```bash
opschain change show-properties --change-id $change_id
```

More detailed information about the specific versions of environment and project [properties](../reference/concepts/properties.md) supplied to each [step](../reference/concepts/concepts.md#step) of the change is available directly from the API server. Using your browser, navigate to `http://localhost:3000/changes/CHANGE_ID` _(where CHANGE_ID is the ID of the change)_. In the API response, each [step](../reference/concepts/concepts.md#step) has a reference to the project and environment [properties](../reference/concepts/properties.md) versions supplied to the [step](../reference/concepts/concepts.md#step).

## Notes on the Confluent example

### Repository Dockerfiles

The repository includes two Dockerfiles

1. The [`Dockerfile`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/.opschain/Dockerfile) in `.opschain` builds a custom OpsChain step runner image that includes the

    - Terraform binary required for the `terraform_config` resource type
    - JRE Installer required for the Confluent containers
    - Confluent Installer required for the Confluent containers

2. The [`Dockerfile`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/Dockerfile) in the repository root is based off a Centos image and defines the image that is used as the basis for the Confluent containers. This image is built as part of the `provision` action, copying the installers from the custom step runner and installing the dynamically generated SSH keys.

### OpsChain runner network

The Terraform `main.tf` file specifies the control center, broker and zookeeper containers should be started on the `opschain-runner-network`. This is the same network as the OpsChain step runner containers and allows the Confluent containers to be referred to via their alias (e.g. broker1).

### External packages

The example makes use of the following packages

- [Terraform Docker provider](https://www.terraform.io/docs/providers/docker)
- [MintPress](https://www.limepoint.com/mintpress) Confluent controller

## What to do next

### Create your own project

Try creating a new project using the steps above and instead of adding a remote, author your own commits. See the [reference documentation](../reference/README.md) and [developing your own resources](../developing_resources.md) guide for more information.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
