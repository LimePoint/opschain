# Changelog

## [2021-06-10]

### Added
- An Oracle WebLogic example project repository is [now available](https://github.com/LimePoint/opschain-examples-weblogic).
- **Feature preview** - platform native builds of the OpsChain CLI are now available for Windows, macOS and Linux. Contact LimePoint support for access.
- OpsChain now supports Active Directory for user authentication and authorisation. See [Configuring an External LDAP](docs/operations/configuring_external_ldap.md)
  - **This change requires the `configure` script to be rerun.**
- OpsChain changes can now be retried from failure or cancellation by using the `opchain change retry` command.
- Updating now safeguards properties whilst a change is active.
  - Step properties are immutable.
  - Project and environment properties can't be updated if they are in use by an active change.

### Changed
- Upgraded Terraform to 0.15.4 in the OpsChain examples.
- Upgraded Terraform plugins in the OpsChain examples - see the commit history of each repository for details.
- Upgraded OpsChain Log Aggregator Image Fluentd to 1.12.4.
- Upgraded MintPress Gems to 3.13.0.
- Upgraded OpsChain DB Image PostgreSQL to 13.3.
- Upgraded OpsChain Auth Image Open Policy Agent 0.29.4.
- Upgraded Bundler to 2.2.19.

## [2021-06-01]

### Added
- The ability to use custom Runner images in the OpsChain Docker development environment. Note that the custom Runner image must have been built as part of an OpsChain change.
  - **This change requires the `configure` script to be rerun.**
- The OpsChain CLI now inherits environment variables. This allows using environment variables to override CLI config or to configure http(s) proxies. Find out more in our [CLI reference](docs/reference/cli.md).
- [OpsChain Operations Guides](docs/operations).
  - [OpsChain Rootless Docker Install](docs/operations/rootless_install.md) documentation.
  - [OpsChain Backups](docs/operations/backups.md) documentation.

## [2021-05-26]

### Added
- The OpsChain platform now includes an Authorisation Server allowing you to restrict user access to projects and environments. See [Restricting User Access](docs/restricting_user_access.md) for more information.
- OpsChain changes can now be cancelled by using the `opschain change cancel` command.

## Changed
- **Breaking Change** - The OpsChain CLI now uses kebab-case-arguments (rather than snake_case_arguments) so all multi word arguments have changed.

## [2021-05-17]

### Important Breaking Changes
- the `opschain_db`, `opschain_ldap` and `opschain_project_git_repos` directories have been moved into a new `opschain_data` directory (`opschain_data` can be overridden as part of the `configure` process)
  - you **must** run `configure` after upgrading to reflect the new directory structure in your `.env` file.
- due to the addition of the project code the OpsChain database needs to be removed and recreated.
  - the path to the project Git repositories has changed from `./opschain_project_git_repos/production/<uuid>` to `./opschain_data/opschain_project_git_repos/<uuid>`.

### Added
- a symbolic link is created as part of the project creation, allowing you to navigate to the project's Git repository via `./opschain_data/opschain_project_git_repos/<project code>`
- **Breaking Change** - projects now use (and require) a unique project code.
- The OpsChain Terraform resource type now supports version 0.15.

### Changed
- Environment codes can now be up to 50 characters long.
- **Breaking Change** - the OpsChain CLI and API have been altered to use the project code as the project identifier rather than the project id.
- The CLI output for the environment and project list commands has changed - the code field is now shown first and the ID is not shown.

### Removed
- The environment delete API has been removed.
- **Breaking Change** - Support for Terraform version 0.14 and lower has been removed from the OpsChain Terraform resource.

## [2021-05-10]

### Added
- OpsChain now supports [automated deployments](docs/reference/concepts.md#automated-deployment) - a way to automatically create OpsChain changes in response to Git changes. See [Setting up an Automated Deployment](docs/automated_deployment.md) for more information.
- OpsChain now supports [scheduled deployments](docs/reference/concepts.md#scheduled-deployment) - a way to automatically create OpsChain changes at a scheduled time.

### Changed
- OpsChain now allows properties to be sourced from a project's Git repository. See the updated [OpsChain Properties Guide](docs/reference/properties.md) for more information.
- OpsChain now does a Git [forced fetch](https://git-scm.com/docs/git-fetch#Documentation/git-fetch.txt---force) when fetching a project's Git repository. This means tags can be updated in the remote and reflected in the project Git repository.

## [2021-04-27]

### Added
- An example project for [running an AWS Ansible change](docs/running_an_aws_ansible_change.md).
- Helper methods available from within actions to store and remove files from Project and Environment Properties. See [Storing & Removing Files](docs/reference/properties.md#storing--removing-files) for more details.

### Changed
- OpsChain environments are now locked such that only one change can be run in an environment at a time. Changes will sit in the `pending` state whilst waiting for the existing change to finish.
- The OpsChain properties available via `OpsChain.properties` are frozen, ensuring users receive an error if they attempt to change them (as only `OpsChain.environment.properties` and `OpsChain.project.properties` are persisted)
- The `terraform_config` resource type now:
    1. automatically stores the Terraform state file in the environment properties.
    2. automatically calls terraform init in the OpsChain Runner prior to running Terraform commands.
- The Confluent and Terraform examples now
    - use Terraform v0.14.9.
    - rely on the new automatic features of the `opschain-terraform` resource.

- The OpsChain Runner now uses
    - Ruby v2.7.3. Please make any necessary adjustments to your project's Git repositories to reflect this change.
    - v3.11.1 of the MintPress Controllers.
- **Breaking Change** - the OpsChain [Files Properties](docs/reference/properties.md#file-properties) format has changed. Any files stored in your properties will need to be altered to reflect the new format.

  _Note: The `properties-show` and `properties-set` features can be used to download, upload your properties (allowing you to edit your properties locally)._

### Fixed
- Hide internal development tasks from the opschain-utils output.
- OpsChain Runner showing "Connection refused - connect(2) for /var/run/docker.sock.opschain" after container restart.

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
- [upgrading.md](docs/operations/upgrading.md) documentation.

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
