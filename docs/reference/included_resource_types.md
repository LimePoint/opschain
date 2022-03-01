# Included resource types

A collection of resource types come pre-installed on the OpsChain step runner image, this guide covers what they are and how to use them.

## Resource type summary

The table below outlines the file to `require` in your resource definition and the resource types that will become available.

| Require                   | Resource Type      | Description                          |
| :------------------------ | :-------------------- | :----------------------------------- |
| `opschain-infrastructure` | `infrastructure_host` | Exposes the [`MintPress::Infrastructure::Host` controller](https://docs.limepoint.com/reference/ruby/MintPress/Infrastructure/Host.html) |
|                           | `transport_factory`   | Exposes the [`MintPress::Infrastructure::TransportFactory` controller](https://docs.limepoint.com/reference/ruby/MintPress/Infrastructure/TransportFactory.html) |
| `opschain-terraform`      | `terraform_config`    | Exposes the [RubyTerraform](https://github.com/infrablocks/ruby_terraform/tree/v1.2.0) gem |

_Note: Contact [LimePoint](mailto:opschain-support@limepoint.com) to obtain the password required to access the MintPress Reference Documentation._

### Usage

The resource types are pre-installed in the OpsChain step runner image via the `opschain-resource-types` gem. To use them, simply add the following line to your `Gemfile` in your project Git repository:

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

## OpsChain Terraform

Requiring `opschain-terraform` provides the `terraform_config` resource type. The resource type will accept any of the [RubyTerraform](https://github.com/infrablocks/ruby_terraform/blob/v1.2.0/README.md) command arguments as properties, but will only pass those supported by the command when the action is invoked.

Please see the [RubyTerraform module documentation](https://infrablocks.github.io/ruby_terraform/RubyTerraform.html) for further information about the available actions and their parameters.

_Note: RubyTerraform supplies `vars` to Terraform on the command line via multiple `-var` parameters. OpsChain overrides this logic by placing the [input variables](https://www.terraform.io/docs/language/values/variables.html) in a [var file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files) and supplying this to Terraform via the `-var-file` parameter to avoid encountering any command line length issues._

### Prerequisites

`opschain-terraform` does not include the Terraform binary. Customers wishing to use the resource type will need to install Terraform in their project's step runner. This can be done by using a [custom step runner Dockerfile](../developing_resources.md#custom-step-runner-dockerfiles), an example of this can be found in the [OpsChain Confluent example](https://github.com/LimePoint/opschain-examples-confluent/blob/75473f7fbac4150b3d5c583dfc52c6b22044552f/.opschain/Dockerfile#L8).

### Automatic Terraform initialisation

The `terraform_config` resource type will automatically execute `terraform init` in the OpsChain runner prior to running any Terraform action.

### Automatic state storage

The `terraform_config` resource type will automatically store the `terraform.tfstate` file in the environment properties after running any Terraform action. This ensures it is available to subsequent steps in your change.

_Note: If the `state_out` property of Terraform is used, the resource type does not automatically store the file. Please use the [`store_file!` feature](concepts/properties.md#storing--removing-files) (after moving the file to the desired location) to store the file._

### Command argument defaults

Default values will be supplied for the following RubyTerraform command arguments:

Parameter    | Default Value | Description
:----------- | :------------ | :-------------------------------------------------------------------------------
auto_approve | true          | Indicates that Terraform should not require interactive approval before applying a plan.
chdir        | `pwd`         | The root directory of your project Git repository within the OpsChain step runner.
input        | false         | Indicates that Terraform should not attempt to prompt for input, and instead expect all necessary values to be provided by either configuration files or the command line.

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
