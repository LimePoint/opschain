# Running a simple Terraform change

Run a simple change that builds an nginx Docker container on your local Docker installation.
It is based on the [Terraform quick start tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started#quick-start-tutorial).

After following this guide you should know how to:

- create a project and environment
- add a remote Git repository as a project remote
- understand how to provide a custom Dockerfile

## Create a project

Create a new project:

```bash
opschain project create --code terraform --name 'Demo Terraform Project' --description 'My Terraform project' --confirm
```

Verify that your new project appears in the list:

```bash
opschain project list
```

## Create an environment

Environments represent the logical infrastructure environments under a project (for example Development or Production).

Create a new environment:

```bash
opschain environment create --project-code terraform --code tform --name 'Terraform Environment' --description 'My Terraform environment' --confirm
```

Verify that your new environment appears in the list:

```bash
opschain environment list --project-code terraform
```

## Add the Terraform example as a remote to the project Git repository

Follow [adding a project Git repository as a remote](../reference/project_git_repositories.md#adding-a-project-git-repository-as-a-remote) using the [OpsChain Terraform example repository](https://github.com/LimePoint/opschain-examples-terraform) remote URL `https://username:password@github.com/LimePoint/opschain-examples-terraform.git`.

## Create a change

Create a new change for the current `origin/master` branch of your project and run the `default` action:

```bash
opschain change create --project-code terraform --environment-code tform --git-rev origin/master --action default --confirm
```

The [steps](../reference/concepts/concepts.md#step) that comprise the change will be shown as well as their status.

_Note: the first step in this change may take a long time as it downloads an nginx Docker image._

**Use the `opschain change show-logs` command to see the log output from the change (including any failures).**

## Verify change deployment

### Check running container

Use Docker to check that you have a **tutorial** container running:

```bash
docker ps -f name=tutorial
```

### View nginx welcome page

Navigate to your [locally running nginx container](http://localhost:8080) to see the welcome page.

### Destroy the container

The container can be stopped and removed by running:

```bash
opschain change create --project-code terraform --environment-code tform --git-rev origin/master --action destroy --confirm
```

_Note: the [verify change deployment](#verify-change-deployment) steps above can be re-run to verify that the container has been stopped._

## Notes on the Terraform example

### Repository Dockerfile

The [`Dockerfile`](https://github.com/LimePoint/opschain-examples-terraform/blob/master/.opschain/Dockerfile) in `.opschain` builds a custom OpsChain step runner image that includes the Terraform binary required for the `terraform_config` resource type.

### External packages

The example makes use of the [Terraform Docker provider](https://www.terraform.io/docs/providers/docker).

## What to do next

### Try a more advanced example

- The [Ansible example](running_an_aws_ansible_change.md) demonstrates how to use OpsChain with Terraform, Ansible and AWS to build and configure a simple nginx instance on AWS

- The [Confluent example](running_a_complex_change.md) demonstrates how to use OpsChain to build and deploy a full [Confluent](https://www.confluent.io) environment using Docker

### Create your own project

Try creating a new project using the steps above and instead of adding a remote, author your own commits. See the [reference documentation](../reference/README.md) and [developing your own resources](../developing_resources.md) guide for more information.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../../LICENCE)
