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

## Configure the target Kubernetes namespace

### Using your own Kubernetes cluster

_If you are using a SaaS demo instance of OpsChain see the section below._

If this example, and your OpsChain API server, are running on your own Kubernetes cluster, you will need to create a namespace and a role that grants the opschain-runner service account, permissions to create the example resources. You can do this by applying the manifest included in this repo.

```bash
kubectl apply -f k8s/namespace.yaml
```

This will create an `opschain-terraform` namespace, and assign relevant permissions to the `opschain-runner` role to allow it to create and destroy the nginx deployment in it.

_Note: this step assumes you are using the default `opschain` Kubernetes namespace for OpsChain. You must modify the `ServiceAccount` namespace in `k8s/namespace.yaml` if this is not the case._

### Using the examples namespace provided as part of your OpsChain SaaS demo

If you are using a SaaS demo instance of OpsChain, an example namespace will have been provisioned for you and the necessary permissions granted to the opschain-runner service account.

To ensure that the correct namespace is passed to Terraform, you will need to add this examples namespace to your OpsChain project properties.

Create the following properties file:

```bash
cat << EOF > terraform_properties.json
{
  "namespace": "<YOUR EXAMPLES NAMESPACE>"
}
EOF
```

Replace `<YOUR EXAMPLES NAMESPACE>` with the examples namespace that was provided to you as part of your OpsChain onboarding.

Apply the properties to the `terraform` project:

```bash
opschain project set-properties --project-code terraform --file-path terraform_properties.json -y
```

## Create a change to deploy nginx

Create a new change for the current `origin/master` branch of your project and run the `default` action:

```bash
opschain change create --project-code terraform --environment-code tform --git-remote-name origin  --git-rev master --action default --confirm
```

The [steps](../reference/concepts/concepts.md#step) that comprise the change will be shown as well as their status.

_Note: the first step in this change may take a long time as it downloads an nginx container image._

**Use the `opschain change show-logs` command to see the log output from the change (including any failures).**

## Verify the change

Once the change has completed successfully, view the change logs. The log output will contain the Kubernetes load balancer status in the form of a Terraform output value.

This value will contain a hostname or IP address that you can use to connect to the service in your browser.

A local Kubernetes cluster (like Docker Desktop) would output something similar to this example:

```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

load_balancer_status = tolist([
  {
    "load_balancer" = tolist([
      {
        "ingress" = tolist([
          {
            "hostname" = "localhost"
            "ip" = ""
          },
        ])
      },
    ])
  },
])
```

Note this value (`localhost`, in the example above) as we will use it to view the nginx welcome page below.

### View the nginx welcome page

Navigate to the nginx welcome page via `http://<load balancer hostname or ip address>:8080` to confirm the successful deployment.

_Note: Replace `<load balancer hostname or ip address>` with the relevant value returned in the Terraform output from the previous step. This will depend on your Kubernetes cluster load balancer implementation._

## Create a change to remove nginx

This change will use Terraform's `destroy` action to remove the Kubernetes resources from the `opschain-terraform` namespace:

```bash
opschain change create --project-code terraform --environment-code tform --git-remote-name origin --git-rev master --action destroy --confirm
```

_Note: the [verify the change](#verify-the-change) steps above can be re-run to verify that nginx has been removed from Kubernetes._

## Customise deployment settings

The example takes advantage of the OpsChain properties to allow you to adjust the nginx port exposed by the Kubernetes cluster.

If you created a `terraform_properties.json` to configure your [target Kubernetes namespace](#using-the-examples-namespace-provided-as-part-of-your-opschain-saas-demo) earlier, edit it and add the `external_port` property e.g.

```json
{
  "namespace": "<YOUR EXAMPLES NAMESPACE>",
  "external_port": 7999
}
```

Alternatively, if you have not already created a properties file, create one containing the following external port property:

```bash
cat << EOF > terraform_properties.json
{
  "external_port": 7999
}
EOF
```

Apply the properties to the `terraform` project:

```bash
opschain project set-properties --project-code terraform --file-path terraform_properties.json -y
```

Now re-run the [create a change to deploy nginx](#create-a-change-to-deploy-nginx) and [verify the change](#verify-the-change) steps, noting how the service names have changed, and nginx is now exposed on port 7999. Finally, re-run the [create a change to remove nginx](#create-a-change-to-remove-nginx) step.

### Remove Kubernetes namespace

If you are running this example on your own Kubernetes cluster, you can now remove the resources you created when you [configured the target namespace](#using-your-own-kubernetes-cluster).

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
