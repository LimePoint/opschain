# Running a complex change

Run a more complex change that builds a multi-node [Confluent](https://www.confluent.io/) setup in your local Kubernetes installation.

After following this guide you should know how to:

- create a project and environment
- add a remote Git repository as a project remote
- set/view properties on the environment
- view the properties used during a change
- understand how to provide a custom Dockerfile

## Prerequisites

This example requires at least 4GB of ram and 50GB of disk space available on the node used to run OpsChain and the example.

If using Docker for Windows or Docker for Mac see our [installation guide](../operations/installation.md#hardwarevm-requirements) for more details.

### Create a project

Create a new project:

```bash
opschain project create --code confluent --name 'Demo Confluent Project' --description 'My Confluent project' --confirm
```

Verify that your new project appears in the list:

```bash
opschain project list
```

### Create an environment

Environments represent the logical infrastructure environments under a project (for example Development or Production).

Create a new environment:

```bash
opschain environment create --project-code confluent --code local --name 'Confluent Environment' --description 'My Confluent environment' --confirm
```

Verify that your new environment appears in the list:

```bash
opschain environment list --project-code confluent
```

### Add the Confluent example as a remote to the project Git repository

Follow [adding a project Git repository as a remote](../reference/project_git_repositories.md#adding-a-project-git-repository-as-a-remote) using the [OpsChain Confluent example repository](https://github.com/LimePoint/opschain-examples-confluent) remote URL `https://{username}:{personal access token}@github.com/LimePoint/opschain-examples-confluent.git`.

### Clone the repository

Clone the Confluent example repository onto your machine:

```bash
git clone https://{username}:{personal access token}@github.com/LimePoint/opschain-examples-confluent.git
cd opschain-examples-confluent
```

### Deploy Kubernetes resources

```bash
kubectl apply -f k8s/namespace.yaml
```

This will create an `opschain-confluent` namespace, and assign relevant permissions to the `opschain-runner` role to allow it to create and destroy the Confluent deployment in it.

_Note: this step assumes you are using the default `opschain` Kubernetes namespace for OpsChain. You must modify the `ServiceAccount` namespace in `k8s/namespace.yaml` if this is not the case._

### Build the base image

Build the base container image used by the example:

```bash
docker build -t confluent-base:latest .
```

The base image includes the installation files for Oracle Java 1.8 and Confluent 6.2, as well as minor changes to the `pam.d` configuration to support containerisation (see the `Dockerfile` in the project root for further details).

_Note: The base image is a basic Linux host running the OpenSSH daemon, allowing it to accept remote connections from OpsChain and should not be used as a basis for real world implementation._

### OpsChain properties

This example takes advantage of the [OpsChain properties](../reference/concepts/properties.md) feature of OpsChain to provide the configuration for the various Confluent servers. The `.opschain/properties.json` file in the Git repository provides the bulk of the configuration information. In addition, an example environment properties file is provided to highlight overriding the project repository defaults with specific values.

#### Import the environment properties

Properties can be loaded from a local file containing a valid JSON object. Use the following command to load the example JSON environment [properties](../reference/concepts/properties.md):

```bash
opschain environment set-properties --project-code confluent --environment-code local --file-path environment_properties.json --confirm
```

These environment [properties](../reference/concepts/properties.md) will override values from the project [properties](../reference/concepts/properties.md)

- `auto.create.topics.enable` - set to false
- `log.retention.check.interval.ms` - set to 301

#### Setting properties dynamically

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
opschain change create --project-code confluent --environment-code local --git-remote-name origin --git-rev master --action default --confirm
```

The [steps](../reference/concepts/concepts.md#step) that comprise the change will be shown as well as their status.

Manually copy and set the change ID as a variable, you'll need it for the next steps:

```bash
change_id=XXXXX
```

**Use the `opschain change show-logs` command to see the log output from the change (including any failures). Use the `--follow` argument to watch the logs as the change progresses.**

## Verify the change

### View the `opschain-confluent` namespace

Use `kubectl` to view the objects deployed in the `opschain-confluent` namespace:

```bash
kubectl get all -n opschain-confluent
```

The namespace will include two **brokers**, a **zookeeper**, and a **control-center**.

_Note the use of a `broker` statefulset to create the brokers, with a headless `kafka` service to provide access to them._

### Check control center settings

Navigate to the _controlcenter.cluster, Cluster Settings, Brokers_  page in your [locally running control center](http://localhost:9021) to see the overridden log retention check interval ms.

### Produce/consume a message via Kafka

First start a consumer on the control center:

```bash
$ kubectl exec -it -n opschain-confluent pod/confluent-control-center -- /bin/bash
[root@confluent-control-center /] export JAVA_HOME=/apps/confluent-demo/binaries/java/
[root@confluent-control-center /] /apps/confluent-demo/binaries/kafka/bin/kafka-console-consumer --bootstrap-server broker-0.kafka.opschain-confluent.svc.cluster.local:9092 --topic demo --from-beginning --group cli-1

```

Then in a new terminal, produce a message:

```bash
$ kubectl exec -it -n opschain-confluent pod/confluent-control-center -- /bin/bash
[root@producer /] export JAVA_HOME=/apps/confluent-demo/binaries/java/
[root@producer /] /apps/confluent-demo/binaries/kafka/bin/kafka-console-producer --broker-list broker-0.kafka.opschain-confluent.svc.cluster.local:9092 --topic demo
> hello there
```

Verify that the message then appears in the consumer terminal:

```bash
[root@confluent-control-center /] /apps/confluent-demo/binaries/kafka/bin/kafka-console-consumer --bootstrap-server broker-0.kafka.opschain-confluent.svc.cluster.local:9092 --topic demo --from-beginning --group cli-1
hello there
```

## Viewing properties used by the change

It can be useful for troubleshooting to know which [properties](../reference/concepts/properties.md) were used by a change when it ran (whether the change was successful or had an error). You can view the merged set of [properties](../reference/concepts/properties.md) that the change started with:

```bash
opschain change show-properties --change-id $change_id
```

More detailed information about the specific versions of environment and project [properties](../reference/concepts/properties.md) supplied to each [step](../reference/concepts/concepts.md#step) of the change is available directly from the API server. Using your browser, navigate to `http://localhost:3000/changes/CHANGE_ID` _(where CHANGE_ID is the ID of the change)_. In the API response, each [step](../reference/concepts/concepts.md#step) has a reference to the project and environment [properties](../reference/concepts/properties.md) versions supplied to the [step](../reference/concepts/concepts.md#step).

## Create a change to remove Confluent

This change will use Terraform's `destroy` action to remove the Kubernetes resources from the `opschain-confluent` namespace:

```bash
opschain change create --project-code confluent --environment-code local --git-remote-name origin --git-rev master --action destroy --confirm
```

_Note: the [verify the change](#verify-the-change) steps above can be re-run to verify that Confluent has been removed from Kubernetes._

### Remove Kubernetes resources

```bash
kubectl delete -f k8s/namespace.yaml
```

This will remove the `opschain-confluent` namespace, and the custom roles associated with the `opschain-runner` for this example.

## Notes on the Confluent example

### Repository Dockerfiles

The repository includes two Dockerfiles:

1. The [`Dockerfile`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/.opschain/Dockerfile) in `.opschain` builds a custom OpsChain step runner image that includes the Terraform binary required for the `terraform_config` resource type.

2. The [`Dockerfile`](https://github.com/LimePoint/opschain-examples-confluent/blob/master/Dockerfile) in the repository root is a RHEL based image that is used as the basis for the Confluent containers. The image includes the JRE and Confluent installation files required by the MintPress controllers to install the application.

### External packages

The example makes use of the following packages

- [Terraform Kubernetes provider](https://www.terraform.io/docs/providers/kubernetes)
- [MintPress](https://www.limepoint.com/mintpress) Confluent controller

## What to do next

### Create your own project

Try creating a new project using the steps above and instead of adding a remote, author your own commits. See the [reference documentation](../reference/README.md) and [developing your own resources](../getting_started/developer.md#developing-resources) guide for more information.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
