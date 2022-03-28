# Running a simple Terraform change

Run a simple change that creates an nginx container in your local Kubernetes stack.
It is based on the [Terraform quick start tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started#quick-start-tutorial).

After following this guide you should know how to:

- create a project and environment
- add a remote Git repository as a project remote
- understand how to provide a custom project Dockerfile

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

### Deploy Kubernetes resources

```bash
kubectl apply -f k8s/namespace.yaml
```

This will create an `opschain-terraform` namespace, and assign relevant permissions to the `opschain-runner` role to allow it to create and destroy the nginx deployment in it.

_Note: this step assumes you are using the default `opschain-trial` Kubernetes namespace for OpsChain. You must modify the `ServiceAccount` namespace in `k8s/namespace.yaml` if this is not the case._

## Create a change to deploy nginx

Create a new change for the current `origin/master` branch of your project and run the `default` action:

```bash
opschain change create --project-code terraform --environment-code tform --git-rev origin/master --action default --confirm
```

The [steps](../reference/concepts/concepts.md#step) that comprise the change will be shown as well as their status.

_Note: the first step in this change may take a long time as it downloads an nginx container image._

**Use the `opschain change show-logs` command to see the log output from the change (including any failures).**

## Verify the change

### View the `opschain-terraform` namespace

Use `kubectl` to view the objects deployed in the `opschain-terraform` namespace:

```bash
kubectl get all -n opschain-terraform
```

The output will include a load balancer that is used to route traffic to the tutorial pod and the nginx container it contains.

### View the nginx welcome page

Navigate to the nginx welcome page via `http://<external-ip>:8080` to confirm the successful deployment.

_Note: Replace `<external-ip>` with the `EXTERNAL-IP` assigned to the `LoadBalancer` in the output from the `kubectl` command executed in the previous step._

## Create a change to remove nginx

This change will use Terraform's `destroy` action to remove the Kubernetes resources from the `opschain-terraform` namespace:

```bash
opschain change create --project-code terraform --environment-code tform --git-rev origin/master --action destroy --confirm
```

_Note: the [verify the change](#verify-the-change) steps above can be re-run to verify that nginx has been removed from Kubernetes._

## Customise deployment settings

The example takes advantage of the OpsChain properties to allow you to adjust the nginx port exposed by the Kubernetes cluster. Create the following properties file:

```bash
mkdir -p cli-files
cat << EOF > cli-files/terraform_properties.json
{
  "external_port": 7999
}
EOF
```

Associate the properties with the `terraform` project:

```bash
opschain project set-properties -p terraform -f cli-files/terraform_properties.json -y
```

Now re-run the [create a change to deploy nginx](#create-a-change-to-deploy-nginx) and [verify the change](#verify-the-change) steps, noting how the service names have changed, and nginx is now exposed on port 7999. Finally, re-run the [create a change to remove nginx](#create-a-change-to-remove-nginx) step.

### Remove Kubernetes resources

```bash
kubectl delete -f k8s/namespace.yaml
```

This will remove the `opschain-terraform` namespace, and the custom roles associated with the `opschain-runner` for this example.

## Notes on the Terraform example

### Repository Dockerfile

The [`Dockerfile`](https://github.com/LimePoint/opschain-examples-terraform/blob/master/.opschain/Dockerfile) in `.opschain` builds a custom OpsChain step runner image that includes the Terraform binary required for the `terraform_config` resource type.

### External packages

The example makes use of the [Terraform Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes).

## What to do next

### Try a more advanced example

- The [Ansible example](running_an_aws_ansible_change.md) demonstrates how to use OpsChain with Terraform, Ansible and AWS to build and configure a simple nginx instance on AWS

- The [Confluent example](running_a_complex_change.md) demonstrates how to use OpsChain to build and deploy a multi-node [Confluent](https://www.confluent.io) environment

### Create your own project

Try creating a new project using the steps above and instead of adding a remote, author your own commits. See the [reference documentation](../reference/README.md) and [developing your own resources](/docs/getting_started/developer.md#developing-resources) guide for more information.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
