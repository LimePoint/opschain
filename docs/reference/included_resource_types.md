# Included resource types

A collection of resource types come pre-installed on the OpsChain step runner image, this guide covers what they are and how to use them.

## Resource type summary

The table below outlines the file to `require` in your resource definition and the resource types that will become available.

| Require                                               | Resource type            | Description                                                                                                                                                      |
| :---------------------------------------------------- | :----------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`opschain-infrastructure`](#opschain-infrastructure) | `infrastructure_host`    | Exposes the [`MintPress::Infrastructure::Host` controller](https://docs.limepoint.com/reference/ruby/MintPress/Infrastructure/Host.html)                         |
|                                                       | `transport_factory`      | Exposes the [`MintPress::Infrastructure::TransportFactory` controller](https://docs.limepoint.com/reference/ruby/MintPress/Infrastructure/TransportFactory.html) |
| [`opschain-kubernetes`](#opschain-kubernetes)         | `kubernetes_resource`    | Manage Kubernetes resources via manifests in your project repo                                                                                                   |
|                                                       | `kubernetes_daemonset`   | Perform common operations on a Kubernetes daemonset resource                                                                                                     |
|                                                       | `kubernetes_deployment`  | Perform common operations on a Kubernetes deployment resource                                                                                                    |
|                                                       | `kubernetes_statefulset` | Perform common operations on a Kubernetes statefulset resource                                                                                                   |
| [`opschain-ssh-key-pair`](#opschain-ssh-key-pair)     | `ssh_key_pair`           | Generate an SSH public/private key pair and optionally stores the key files in OpsChain properties                                                               |
| [`opschain-terraform`](#opschain-terraform)           | `terraform_config`       | Exposes the [RubyTerraform](https://github.com/infrablocks/ruby_terraform/tree/v1.6.0) Gem                                                                       |

_Note: Contact [LimePoint](mailto:opschain-support@limepoint.com) to obtain the password required to access the MintPress Reference Documentation._

### Usage

The resource types are pre-installed in the OpsChain step runner image via the `opschain-resource-types` Gem. To use them, simply add the following line to your `Gemfile` in your project Git repository:

```ruby
gem 'opschain-resource-types'
```

Then in your `actions.rb` (or wherever you define your resources) add:

```ruby
# replace 'opschain-infrastructure' with the relevant value from the "Require" column in the table above
require 'opschain-infrastructure'

# replace transport_factory with the required resource type from the "Resource Type" column in the table above
transport_factory :my_transport_factory do
  ...
end
```

## OpsChain infrastructure

Requiring `opschain-infrastructure` currently provides a minimal set of resource types for the [Confluent OpsChain example project](https://github.com/LimePoint/opschain-examples-confluent). More support will be added over time.

## OpsChain Kubernetes

Requiring `opschain-kubernetes` provides several resources for working with Kubernetes. These resources wrap the `kubectl` binary to allow you to perform some common Kubernetes operations.

### Prerequisites

The `kubectl` binary must be available in your runner environment and is not included by default. To install `kubectl`, a [custom Dockerfile](concepts/step_runner.md#custom-step-runner-dockerfiles) must be included in your project's `.opschain` directory.

Below is an example Dockerfile RUN directive for adding `kubectl` to your runner.

```Dockerfile
...
# Run any Dockerfile commands that don't rely on the contents of the Git repository here to avoid rerunning them when the Git repo changes.
RUN curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl
...
```

### Authentication

There are multiple options available to authenticate with the Kubernetes cluster that you want to manage.

#### In-cluster service account config

By default, the `opschain-kubernetes` resource will use the `opschain-runner` service account to manage Kubernetes resources in the same cluster that OpsChain runs. You will need to grant the `opschain-runner` additional permissions to manage resources in your desired namespace(s) via additional RoleBindings or ClusterRoleBindings. Managing roles & permissions in your cluster is outside the scope of this documentation. Please see the [Kubenetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) for more details.

#### Kubeconfig via OpsChain file properties

If you need to manage Kubernetes resources in another cluster, or don't want to use the `opschain-runner` service account as your identity, you can provide a custom [kubeconfig file](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) that will be read by `kubectl`. To do this, add a kubeconfig file via OpsChain file properties with the path `/opt/opschain/.kube/config`. See the [OpsChain properties documentation](concepts/properties.md#file-properties) for more information on adding file properties.

To use an alternative kubeconfig path set the [KUBECONFIG](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable) environment variable via [OpsChain properties](concepts/properties.md#environment-variables).

### Resource Types

#### kubernetes_resource

The `kubernetes_resource` type provides a generic type with `apply` and `delete` actions for managing any valid Kubernetes resources via manifest files present in your project repository.

```ruby
kubernetes_resource :nginx do
  manifest_path 'k8s/nginx.yaml'
  namespace 'myapp'
end
# provides nginx:apply and nginx:delete actions
```

#### kubernetes_daemonset, kubernetes_deployment, kubernetes_statefulset

The `kubernetes_daemonset`, `kubernetes_deployment`, and `kubernetes_statefulset` resource types provide actions for performing `restart`, `scale`, and `wait` operations on the standard 'workload' resources running within a Kubernetes cluster.

All three of these resource types provide the same functionality, but are provided as separately named types to account for how the resources are addressed within Kubernetes.

```ruby
kubernetes_deployment :nginx do
  name 'nginx'
  namespace 'myapp'
  replicas 1
  wait_for_condition 'Available'
end
# provides nginx:restart, nginx:scale, and nginx:wait actions
```

### Utilities

#### Logs

The `kubernetes_daemonset`, `kubernetes_deployment`, and `kubernetes_statefulset` types also provide access to a `logs` method on their controller.

The `logs` method requires you to pass a `tail: <number of lines>` argument to specify the number of log lines you would like returned. If you would like to return all log lines for the lifespan of the pod, you can use `tail: -1`. **PLEASE NOTE** that if your workload is a particularly noisy logger, this may result in a large amount of logs being buffered into memory, so use this with caution.

```ruby
kubernetes_deployment :nginx do
  name 'nginx'
  namespace 'myapp'

  desc 'Wait until nginx deployment is available and show logs'
  action logs: ['nginx:wait'] do
    controller.logs(tail: 100).each do |line|
      OpsChain.logger.info line
    end
  end
end
```

By default, logs will return the logs for all containers in a pod, but you can also provide a `container: '<container name>'` argument to only return logs from a single container from within the pod.

```ruby
action :logs do
  logs = controller.logs(tail: 100, container: 'app')
  # do something with logs
end
```

## OpsChain SSH key pair

Requiring `opschain-ssh-key-pair` provides the `ssh_key_pair` resource type.

### Resource type properties

The `ssh_key_pair` resource type accepts the following properties:

| Property      | Default value        | Description                                                                                                                                                                                                                                                                                                                                                                                                        |
| :------------ | :------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `key_path`    | `/opt/opschain/.ssh` | The location to generate the SSH key pair. <br/>_Note: the default path is the `opschain` user's default SSH path._                                                                                                                                                                                                                                                                                                |
| `private_key` | `id_rsa`             | The file name of the private key to generate (if a DSA type key is generated, the private key file name will default to `id_dsa`).                                                                                                                                                                                                                                                                                 |
| `public_key`  | `id_rsa.pub`         | The file name of the public key to generate (if a DSA type key is generated, the public key file name will default to `id_dsa.pub`).                                                                                                                                                                                                                                                                               |
| `type`        | `RSA`                | The type of key to generate. Valid values are: <br/> - `RSA` <br/> - `DSA`                                                                                                                                                                                                                                                                                                                                         |
| `bits`        | `4096`               | Determines the strength of the key in bits as an integer.                                                                                                                                                                                                                                                                                                                                                          |
| `store_in`    | `:environment`       | The OpsChain properties to store the generated key pair. Valid values are: <br/> - `:environment` the key pair will be stored in the OpsChain environment properties <br/> - `:project`  the key pair will be stored in the OpsChain project properties <br/> - `nil` the key pair will not be automatically stored in OpsChain properties (see [notes on key storage](#notes-on-key-storage) below)               |
| `passphrase`  |                      | Optional passphrase to assign to the private key.                                                                                                                                                                                                                                                                                                                                                                  |

### Actions

The `ssh_key_pair` resource type provides the following actions:

| Action              | Description                                                                                                                                                                                                                                                                                  |
| :------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `create`            | Creates an SSH public/private key pair inside the `key_path` folder with the filenames specified by `public_key`/`private_key` and optionally stores the files in OpsChain properties. <br/>_Note: If the `private_key` or `public_key` exists in the `key_path`, they will be overwritten_. |
| `create_if_missing` | Validates that the `private_key` and `public_key` exists in the `key_path`. If either is missing, generates a new key pair and optionally stores the key pair in the OpsChain properties.                                                                                                    |

#### Notes on key storage

The SSH key pair will be generated inside the OpsChain step runner container. By default the key pair will be stored in the OpsChain environment properties, making them accessible to future changes run in this environment (and subsequent steps in the current change). If you wish to use the key pair in other environments within the project, set the `store_in` resource property to `:project`. The key pair will then be stored in the OpsChain project properties and available to all changes run in that project.

If you do not wish to store the key pair in the OpsChain properties, `store_in` can be set to `nil`. _Please note: If you do not store the generated keys in OpsChain properties, they will cease to exist when the step runner container is removed. For this reason, ensure the step stores the keys (e.g. in [Hashicorp Vault](https://www.vaultproject.io), as a [Kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/), on another server, etc..) to allow them to be used in the future._

## Examples

The [OpsChain AWS Ansible](https://github.com/LimePoint/opschain-examples-ansible), [OpsChain Confluent](https://github.com/LimePoint/opschain-examples-confluent) and [OpsChain WebLogic](https://github.com/LimePoint/opschain-examples-weblogic) example projects all make use of the `ssh_key_pair` resource type to generate SSH key pairs for their respective target containers.

## OpsChain Terraform

Requiring `opschain-terraform` provides the `terraform_config` resource type. The resource type will accept any of the [RubyTerraform](https://github.com/infrablocks/ruby_terraform/blob/v1.6.0/README.md) command arguments as properties, but will only pass those supported by the command when the action is invoked.

Please see the [RubyTerraform module documentation](https://infrablocks.github.io/ruby_terraform/RubyTerraform.html) for further information about the available actions and their parameters.

_Note: RubyTerraform supplies `vars` to Terraform on the command line via multiple `-var` parameters. OpsChain overrides this logic by placing the [input variables](https://www.terraform.io/docs/language/values/variables.html) in a [var file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files) and supplying this to Terraform via the `-var-file` parameter to avoid encountering any command line length issues._

### Prerequisites

`opschain-terraform` does not include the Terraform binary. Customers wishing to use the resource type will need to install Terraform in their project's step runner. This can be done by using a [custom step runner Dockerfile](concepts/step_runner.md#custom-step-runner-dockerfiles). An example of this can be found in the [OpsChain Confluent example](https://github.com/LimePoint/opschain-examples-confluent/blob/75473f7fbac4150b3d5c583dfc52c6b22044552f/.opschain/Dockerfile#L8).

### Automatic Terraform initialisation

The `terraform_config` resource type will automatically execute `terraform init` in the OpsChain runner prior to running any Terraform action.

### Automatic state storage

The `terraform_config` resource type will automatically store the `terraform.tfstate` file in the environment properties after running any Terraform action. This ensures that the file is available to subsequent steps in your change.

_Note: If the `state_out` property of Terraform is used, the resource type does not automatically store the file. Please use the [`store_file!` feature](concepts/properties.md#storing--removing-files) (after moving the file to the desired location) to store the file._

### Command argument defaults

Default values will be supplied for the following RubyTerraform command arguments:

| Argument     | Default value | Description                                                                                                                                                                |
|:-------------| :------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| auto_approve | true          | Indicates that Terraform should not require interactive approval before applying a plan.                                                                                   |
| chdir        | `pwd`         | The root directory of your project Git repository within the OpsChain step runner.                                                                                         |
| input        | false         | Indicates that Terraform should not attempt to prompt for input, and instead expect all necessary values to be provided by either configuration files or the command line. |

_Note: Resources can override these values if required._

### Terraform automation environment variable

The Terraform `TF_IN_AUTOMATION` environment variable is automatically configured when running `terraform_config` actions. This will indicate to Terraform that there is some wrapping application executing terraform and cause it to make adjustments to its output to de-emphasize specific commands to run next. For further information see [controlling Terraform output in automation](https://learn.hashicorp.com/tutorials/terraform/automate-terraform#controlling-terraform-output-in-automation).

## Examples

The [OpsChain Terraform example project](https://github.com/LimePoint/opschain-examples-terraform) demonstrates how the OpsChain Terraform resource type can be used.

The [OpsChain AWS Ansible example project](https://github.com/LimePoint/opschain-examples-ansible) demonstrates how the OpsChain Infrastructure and OpsChain Terraform resource types can be combined with Ansible to deploy an nginx host on AWS.

The [OpsChain Confluent example project](https://github.com/LimePoint/opschain-examples-confluent) demonstrates how the OpsChain Infrastructure and OpsChain Terraform resource types can be used together.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
