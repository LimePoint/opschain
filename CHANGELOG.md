# Changelog

## [2021-03-31]

### Added
- An example project for [running a simple Terraform change](docs/running_a_simple_terraform_change.md).
- The Getting Started guide now includes instructions for creating your own action.

### Changed
- The sample data provided as part of the Getting Started guide has been simplified.
- The `.opschain/step_context.json` file is now optional when running `opschain-action` or `opschain-dev`.
- The `terraform_config` resource type passes any `vars` ([Terraform Input Variables](https://www.terraform.io/docs/language/values/variables.html)) supplied to Terraform via a [var file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files).

### Removed
- The [Confluent Example](https://github.com/LimePoint/opschain-examples-confluent) no longer provides the VarFile class as its functionality has been added to the `terraform_config` resource type.

## [2021-03-22]

### Added
- The `opschain-resource-types` gem is now pre-installed in the OpsChain Step Runner Image providing some [resource types](docs/reference/included_resource_types.md) for the `mintpress-infrastructure` and `ruby-terraform` gems.

  _Please note the [Prerequisites](docs/reference/included_resource_types.md#prerequisites) for the Terraform resource._

### Changed
- Replaced `mintpress-infrastructure` resource types in the [Confluent Example](https://github.com/LimePoint/opschain-examples-confluent) with those provided by the pre-installed `opschain-resource-types` gem in the OpsChain Step Runner Image.
- [Confluent Example](https://github.com/LimePoint/opschain-examples-confluent) Properties
  - Replaced encrypted project properties with unencrypted properties.
  - The host environment for the brokers and control center is now sourced from OpsChain properties.

  _Please note, you will need to [update the project properties](running_a_complex_change.md#import-the-confluent-example-properties) with the new `project_properties.json` before re-running the example._

- The Terraform binary is now installed in the Custom Step Runner Dockerfile as part of the [OpsChain Confluent Example](https://github.com/LimePoint/opschain-examples-confluent/blob/75473f7fbac4150b3d5c583dfc52c6b22044552f/.opschain/Dockerfile#L8)

### Removed
- Removed decryption support from example code until MintAESEncryption is fully supported.
- Removed `BUNDLE_CIBUILDER__MINTPRESS_IO` var (from `.env.example`) since it is not used.
- The Terraform binary has been removed from the OpsChain Step Runner Image for parity with other tools which we support but don't bundle.
- Terraform support has been removed from the `opschain-core` gem (Terraform support is now available via the `opschain-resource-types` gem).

## [2021-03-09]

### Added
- Automatically expose [Controller Actions and Properties](docs/reference/actions.md#controller-actions-and-properties) in resource types and resources.
- [upgrading.md](docs/upgrading.md) documentation.

### Changed
- Upgraded OpsChain Log Aggregator Image Fluentd from version 1.11 to 1.12.1
- Upgraded OpsChain LDAP Image OpenLDAP from version 2.4.50 to 2.4.57
- Upgraded OpsChain DB Image Postgres from 13.1 to 13.2
- Upgraded OpsChain Step Runner Image Terraform from 0.12.29 to 0.14.7.

  _Please note:_
  1. Project Git repositories will need to be updated:_

      - [Terraform 0.12 -> 0.13](https://www.terraform.io/upgrade-guides/0-13.html) - will assist in creating a `versions.tf` in your project Git repository(s).
      - [Terraform 0.13 -> 0.14](https://www.terraform.io/upgrade-guides/0-14.html) - provides information on the new `.terraform.lock.hcl` lock file.

  2. You will need to [update the environment properties](running_a_complex_change.md#import-the-confluent-example-properties) with the `environment_properties.json` before re-running the example (to remove the old `tfstate` information)._
