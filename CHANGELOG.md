# Changelog

## 2022-06-20

### Added

- `OpsChain.context.change.automated` is now populated in the [OpsChain context](docs/reference/concepts/context.md) - indicating whether a change was created by an [automated change rule](docs/reference/concepts/automated_changes.md).
- The `automated` field is now included in the OpsChain changes API response - indicating whether a change was created by an [automated change rule](docs/reference/concepts/automated_changes.md).

### Changed

- The OpsChain CLI now displays the provided command line argument values before prompting for any required values.
- Upgraded all base images used by the OpsChain examples to AlmaLinux 8.6.
- Upgraded Bundler to 2.3.15.
- Upgraded HashiCorp Vault to 1.10.3 in the OpsChain Vault example.
- Upgraded Kong to v2.8.2.
- Upgraded OPA to v0.41.0.
- Upgraded PostgreSQL to 14.3.
- The `ruby-terraform` Gem version supported by the `opschain-resource-types` Gem has been updated to v1.5.0.
- Upgraded Terraform to 1.2.2 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' provider to 4.17.0 in the OpsChain Ansible example.
- Upgraded the base OS for the OpsChain LDAP server to Debian bullseye
- Upgraded the OpsChain base runner image to AlmaLinux 8.6.
- Upgraded the CLI to Node.js v16.15.1.

## 2022-06-08

### Important breaking changes

- OpsChain must be installed from scratch for this release. Follow the steps in the [uninstall guide](docs/operations/uninstall.md) to remove OpsChain and then perform a [fresh install](docs/operations/installation.md). The existing Git remotes can be re-used with the new installation.

### Added

- When the list of options for an argument contains a single value, the OpsChain CLI will now automatically select it.
- OpsChain now tracks the Git remote used for a change explicitly.
- OpsChain now tracks the Git remote used for an automated change rule explicitly.

### Changed

- **Breaking changes**
  - When creating a change the Git remote and revision must be specified individually via the `--git-remote-name` and `--git-rev` options.
  - When creating an automated change rule the Git remote and revision must be specified individually via the `--git-remote-name` and `--git-rev` options.
  - The `GIT_REV` build argument provided to custom project `Dockerfile`s no longer includes the remote name.

### Fixed

- [Wait steps](docs/reference/concepts/actions.md#wait-steps) within namespaces now work as expected.
- A sporadic bug whilst running changes or using `opschain dev` - `iseq_compile_each: unknown node (NODE_SCOPE) (SyntaxError)` - has been fixed.

## 2022-05-25

### Known issues

- OpsChain changes may fail with `BUG: error: failed to solve ...`. See the [troubleshooting guide](docs/troubleshooting.md#opschain-change---bug-error-failed-to-solve) to learn how to resolve this issue.

### Added

- The `opschain change show-logs` command now supports the `--timestamps` option, to prefix each log line with the date and time it was logged.
- OpsChain now supports [wait steps](docs/reference/concepts/actions.md#wait-steps) - steps that pause a change execution and wait for a user to continue the change manually.
- CLI version, server version and runner image can be retrieved via the `opschain info` CLI command.
- An `/info` endpoint has been added to the OpsChain API to return the currently running version and runner image.

### Changed

- Upgraded Bundler to 2.3.12.
- Upgraded Fluent Bit to v1.9.3.
- Upgraded BuildKit to v0.10.3
- Upgraded OPA to v0.40.0.
- Upgraded Terraform to 1.1.9 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' provider to 4.13.0 in the OpsChain Ansible example.
- Upgraded Terraform 'hashicorp/kubernetes' provider to 2.11.0 in the OpsChain WebLogic, Terraform, and Confluent examples.
- Upgraded HashiCorp Vault to 1.9.6 in the OpsChain Vault example.
- Upgraded Confluent to 6.2.4 in the OpsChain Confluent example.
- Upgraded Kong to v2.8.1.
- Upgraded Kong ingress controller to v2.3.1.

### Fixed

- Added the missing `OpsChain.repository.properties` method that is described in the Git repository section of the [properties guide](docs/reference/concepts/properties.md#git-repository).
- The project links in the Git remotes response body.
- Fixed runner image building on macOS M1 hosts.

## [2022-05-09]

### Added

- OpsChain project Git remotes can now be queried using the `opschain project list-git-remotes` command.

### Changed

- The `opschain-dev` command has been replaced with a new CLI command `opschain dev`. Execute `opschain dev --help` for more information.
- the `opschain-lint` Git pre-commit hook has been updated and should be recreated in your project Git repositories. From within the OpsChain development environment, execute `rm -f .git/hooks/pre-commit && opschain-lint --setup`
- Outside the development environment:
  - the `opschain-action` command is no longer available.
  - the `opschain-lint` command has been replaced with a new OpsChain CLI command `opschain dev lint`.
  - The `opschain-utils dockerfile_template` command has been replaced with a new OpsChain CLI command `opschain dev create-dockerfile`

### Fixed

- Updates to properties made by parallel steps are now applied correctly.

## [2022-05-05]

### Added

- Documentation has been added explaining how container image builds can be achieved with OpsChain. [Learn more](docs/reference/building_container_images.md).
- A link to the step's log lines is now included in the step JSON.
- The `opschain change create` command now accepts the `--background` argument, allowing you to create changes and not follow their progress.

### Fixed

- The OpsChain licence has been fixed in the OpsChain development environment.

## [2022-04-20]

### Added

- The OpsChain CLI request timeout can now be modified. [Learn more](docs/reference/cli.md#opschain-cli-configuration-settings).
- Log messages pertaining to the step phases. [Learn more](docs/reference/concepts/step_runner.md#log-messages-for-step-phases).

### Changed

- The OpsChain CLI will now retry lookup requests (up to three times total) if they fail due to timeouts.
- Upgraded Ruby to 2.7.6.
- Upgraded Bundler to 2.3.11.
- Upgraded Fluentd to v1.14.6-1.0.
- Upgraded Fluent Bit to v1.9.2.
- Upgraded BuildKit to v0.10.1
- Upgraded OPA to v0.39.0.
- Upgraded Terraform to 1.1.8 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' provider to 4.9.0 in the OpsChain Ansible example.
- Upgraded Terraform 'hashicorp/kubernetes' provider to 2.10.0 in the OpsChain WebLogic, Terraform, and Confluent examples.
- Upgraded HashiCorp Vault to 1.9.4 in the OpsChain Vault example.
- Upgraded Confluent to 6.2.3 in the OpsChain Confluent example.
- Upgraded recommended cert-manager version to v1.8.0.
- Upgraded Kong ingress controller to v2.3.1.
- A full backtrace will be shown in the change logs when an action raises an error.
- **Breaking changes**
  - The `OPSCHAIN_IMAGE_TAG` variable has been renamed `OPSCHAIN_VERSION`.
  - The `opschain.lic` path has changed in the custom Dockerfile, it is now stored in `/` in the runner image.

  _Use the `opschain-utils dockerfile_template` command to see the new Dockerfile format and ensure any custom project Dockerfiles are updated to reflect these changes._

## [2022-04-11]

### Added

- The OpsChain CLI now supports [shell completion](docs/reference/cli.md#shell-completion).
- OpsChain now supports SSH authentication (in addition to password authentication) for Git remotes.
  - There is an SSH `known_hosts` file provided by OpsChain. See [the documentation](docs/reference/project_git_repositories.md#ssh-git-remotes) if you need to know more about this file.

### Changed

- The `opschain project set-git-remote` arguments have been updated to support the new authentication options.
- The OpsChain CLI examples for `set-properties` no longer use the `cli-files` folder as the native binary does not require it.

## [2022-03-28]

### Added

- Documentation on the [change and step behaviour](docs/reference/concepts/concepts.md#behaviour-when-a-child-step-fails) when a failure occurs in one of the child steps.
- OpsChain action method validation can now be [disabled](docs/reference/concepts/actions.md#controller-action-method-validation).

### Changed

- **Breaking changes**
  - OpsChain has moved from Docker Compose to Kubernetes. Only single node Kubernetes deployments are supported currently.
    - There is no migration path for data from previous versions of OpsChain to the current version.
    - This release of OpsChain must be installed from scratch.
    - Most of the OpsChain processes documented in the [OpsChain operations guides](docs/operations/README.md) have changed.
  - The OpsChain runner Dockerfile now utilises the OPSCHAIN_BASE_RUNNER build argument to determine the FROM image. Use the `opschain-utils dockerfile_template` command to see the new format and ensure any custom project Dockerfiles are updated to reflect this change.
- When running changes that include parallel child steps, if one of those children fails, the `opschain change create` command will continue running until all its siblings have finished.
- Upgraded Fluentd to v1.14.5-1.1.
- Upgraded OPA to 0.38.1.
- Upgraded PostgreSQL to 14.2.
- Upgraded Terraform to 1.1.7 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' plugin to 4.5.0 in the OpsChain Ansible example.
- Upgraded the OpsChain base runner image to AlmaLinux 8.5.
- All base images used by the OpsChain examples upgraded to AlmaLinux 8.5
- When running changes that include parallel child steps, if one of those children fails, the `opschain change create` command will continue running until all its siblings have finished.

### Fixed

- When following the change logs, OpsChain will display all the logs until the change completes - previously the final log messages may not have been shown.

## [2022-03-01]

### Added

- The OpsChain hardware requirements are now [documented](docs/operations/installation.md#hardwarevm-requirements).
- The `opschain change show-logs` command now accepts a `--follow` argument to follow the logs until the change completes.
- [Documentation](docs/reference/concepts/properties.md#changing-properties-in-parallel-steps) and [troubleshooting guide](docs/troubleshooting.md#updates-made-to-properties-could-not-be-applied) when changing properties within parallel steps.
- Added [Kubernetes resource types](docs/reference/included_resource_types.md#opschain-kubernetes).
- Added an [SSH key pair](docs/reference/included_resource_types.md#opschain-ssh-key-pair) resource type.

### Changed

- Upgraded Rails to 7.
- Upgraded Ruby to 2.7.5.
- Upgraded PostgreSQL to 14.1.
- Upgraded Bundler to 2.3.6.
- Upgraded OPA to 0.36.0.
- Upgraded Fluentd to v1.14.4-1.0.
- Upgraded Terraform to 1.1.4 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' plugin to 3.73.0 in the OpsChain Ansible example.
- Upgraded HashiCorp Vault to 1.9.2 in the OpsChain Vault example.
- Upgraded Confluent to 6.2.2 in the OpsChain Confluent example.
- Update example on [setting environment variables](docs/reference/concepts/properties.md#setting-environment-variables-example) in the [OpsChain properties guide](docs/reference/concepts/properties.md#opschain-properties-guide).
- Update documentation on the [minimum requirements](docs/reference/project_git_repositories.md#minimum-requirements) in the [OpsChain project Git repositories guide](docs/reference/project_git_repositories.md#opschain-project-git-repositories-guide).
- The OpsChain base runner image is now based on AlmaLinux 8.

### Fixed

- Properties raising `ActiveRecord::StaleObjectError` exception when parallel steps modify properties.
- API worker now logs the full stack trace for `Failed processing step <step_name> (ProcessStepResultCommand::Error)` exception when patching properties fails.

## [2021-11-12]

### Added

- Reference for all third party software licences used in our applications.
- Document our [support policy](docs/support.md). This includes the type of support we provide when using OpsChain, as well as details on how and when to contact our support team.
- In addition to lightweight tags, OpsChain now supports creating changes that reference annotated tags. See [creating tags](https://git-scm.com/book/en/v2/Git-Basics-Tagging) for more information on Git tag types.
- When run in a dirty Git repository, the OpsChain CLI now prints a warning when creating a change to alert the user that their updates may not be committed yet.
- **Breaking changes**
  - OpsChain now requires an `opschain.lic` licence file to operate. Please use the [`#opschain-trial` Slack channel](https://limepoint.slack.com/messages/opschain-trial) to request a licence.
  - Custom runner base images now require ONBUILD steps to ensure the OpsChain licence is available to the runner. For further details see [image performance - base images](docs/reference/concepts/step_runner.md#image-performance---base-images).
- Documentation on how to [uninstall](docs/operations/uninstall.md) OpsChain.

### Changed

- The `configure` script won't re-ask questions that can't change.
- Upgraded Bundler to 2.2.30.
- Upgraded OPA to 0.34.0.
- Upgraded Fluentd to 1.14.2-1.0.
- Upgraded Terraform to 1.0.10 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' plugin to 3.63.0 in the OpsChain Ansible example.
- The OpsChain step runner Docker image is now built with Docker BuildKit.

### Removed

- The LimePoint MintPress licence is no longer required to use OpsChain.

## [2021-10-26]

### Added

- Change specific logs are now available from the `/changes/<change_id>/log_lines` API. The results can be filtered using the same filtering syntax as events.
- The OpsChain DSL now supports
  - referencing resource properties by name within `action` blocks - see [defining resource types & resources](docs/reference/concepts/actions.md#defining-resource-types--resources).
  - referencing composite resource properties by name within child resources - see [defining composite resources](docs/reference/concepts/actions.md#defining-composite-resources--resource-types).
  - referencing resources by name from within actions and when setting properties - see [referencing resources](docs/reference/concepts/actions.md#referencing-resources)

### Changed

- On startup, OpsChain now displays the publicly mapped port it is listening on.
- Upgraded Bundler to 2.2.28.
- Upgraded OPA to 0.33.0.
- Upgraded Fluentd to 1.14.1-1.0.
- Upgraded Terraform to 1.0.8 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' plugin to 3.62.0 in the OpsChain Ansible example.
- Upgraded HashiCorp Vault to 1.8.4 in the OpsChain Vault example.
- Upgraded Confluent to 6.2.1 in the OpsChain Confluent example.
- Parallel child steps are now run in serial when run in the `opschain-dev` development environment.
- **Breaking changes**
  - the `/log_lines` endpoint
    - returns at most 10,000 log lines.
    - requires a filter using the same filtering syntax as events.
  - upgraded PostgreSQL to 14.0 (your database must be re-created, or manually upgraded).
  - the `resource_properties` resource method in the OpsChain DSL has been replaced with `properties`.
  - the OpsChain DSL `Scope` class has been restructured and is for internal use only.

### Removed

- **Breaking change** - the `/log_lines` endpoint no longer accepts the `change_id` URL parameter

## [2021-09-28]

You **must** run `configure` after upgrading to update the `.env` file with the log configuration update.

### Added

- `opschain-lint` is automatically added as a Git pre-commit hook for new project Git repositories.
- The `configure` script now shows an error when it fails.
- An OpsChain banner message is displayed once the API is ready.
- OpsChain API documentation is now available from the API server [http://localhost:3000/docs](http://localhost:3000/docs).

### Changed

- The `configure` script now resolves the absolute path for the OPSCHAIN_DATA_DIR.
- **Breaking change** - The OpsChain runner image has been split meaning the MintPress Oracle controllers are not available by default.
  - See the [enterprise controllers for Oracle](docs/reference/opschain_and_mintpress.md#enterprise-controllers-for-oracle) guide for more details.

### Fixed

- Repeated invocations of the `configure` script on macOS have been fixed - they used to fail silently.
- OpsChain runners on Windows and macOS were failing as the log configuration was wrong.

## [2021-09-03]

### Added

- The OpsChain CLI can now:
  - be configured to output the step statuses as text rather than emoji. See the [CLI configuration guide](docs/reference/cli.md#opschain-cli-configuration-settings) for more details.
  - archive projects and environments. See the [archiving projects & environments guide](docs/reference/concepts/archiving.md) for more details.
- The OpsChain DSL now supports the `ref` method for referencing other resources. This is useful for cases where a resource name includes special characters, e.g.:

  ```ruby
  infrastructure_host 'test.opschain.io'

  some_resource 'something' do
    host ref('test.opschain.io') # `host test.opschain.io` would fail here
  end
  ```

- The OpsChain API `projects` and `environments` endpoints now
  - return a boolean `archived` attribute.
  - accept `DELETE` requests. _Note: Only projects and environments with no associated changes can be deleted._
- The OpsChain API `automated_change_rules` endpoint now includes a `next_run_at` attribute containing the time when the rule will next run. See the [automated changes guide](docs/reference/concepts/automated_changes.md#creating-an-automated-change-rule-for-new-commits) for more information on what happens when an automated change rule runs.
- The `opschain automated-change list` output no longer include the `Project` and `Environment` columns (as these are parameter values to the command) and includes a `Next Run At` column.
- The `opschain-action` command now supports a _best-effort_ mode for running the child steps of an action. See the [child steps](docs/docker_development_environment.md#child-steps) section of the Docker development environment guide for more details.
- OpsChain now provides an `opschain-lint` command for detecting issues with the OpsChain DSL. Learn more in the [Docker development environment](docs/docker_development_environment.md#using-opschain-lint) guide.
  - `opschain-lint` is run as part of the default Dockerfile for steps to detect errors sooner - this can be added to custom Dockerfiles, or a custom Dockerfile could be used to remove the linter if it is not desired.

### Fixed

- A rare logging error reported by the OpsChain worker - `(JSON::ParserError) (Excon::Error::Socket)`/`socat[323] E write(., ..., ...): Broken pipe` - has been fixed.
- A rare Terraform error where the temporary var file was removed prior to Terraform completing has been fixed.

### Changed

- Upgraded Bundler to 2.2.26.
- Upgraded Postgres to 13.4.
- Upgraded Terraform to 1.0.5 in the OpsChain examples.
- Upgraded Terraform 'hashicorp/aws' plugin to 3.56.0 in the OpsChain Ansible example.
- Upgraded Terraform 'kreuzwerker/docker' plugin to 2.15.0 in the OpsChain Confluent, Terraform & Weblogic examples.
- Upgraded HashiCorp Vault to 1.8.2 in the OpsChain Vault example.

## [2021-08-16]

### Added

- OpsChain now supports events. The `/events` endpoint can be used for reporting and auditing, see the [events](docs/reference/concepts/events.md) guide for more details.
- The list of configuration in the `.env` file is now documented in the [configuration options](docs/operations/configuring_opschain.md) guide.
- Changes can now take metadata (JSON structured data) to help identify and track changes.
  - The `opschain change create/retry` commands now takes an optional argument to allow providing the metadata for a change.
    - If provided, the metadata file must contain a JSON object, e.g. `{ "cr": "CR73", "description": "Change request 73 - apply patchset abc to xyz." }`.
  - The `opschain change show/list` commands now include the change metadata.
  - The `/changes` API can now be filtered using the same filtering syntax as events.
    - For example, `?filter[metadata_cr_eq]=CR73` would match all changes with the metadata `{ "cr": "CR73" }`.
    - See the [events filtering](docs/reference/concepts/events.md#filtering-events) documentation for more details.

### Changed

- Simplified the `.env` file by moving default values to `.env.internal`
- The OpsChain log aggregator no longer requires that port 24224 is available - it now uses a Docker managed random port

### Fixed

- A number of broken links in the documentation have been fixed

## [2021-08-04]

### Added

- Support for alternative spelling of `mintpress.license` in the `configure` script.

### Changed

- The OpsChain change log retention guide has moved and been renamed to [OpsChain data retention](docs/operations/maintenance/data_retention.md).
- **Breaking change** - the `OPSCHAIN_ARCHIVE_LOG_LINES_JOB_CRON` config variable has been renamed to `OPSCHAIN_CLEAN_OLD_DATA_JOB_CRON`.
- **Breaking change** - Upgraded Ruby to 2.7.4 on the OpsChain Step Runner.
  - If required, please update the `.ruby_version` in your project Git repositories.
- Upgraded Bundler to 2.2.25.
- Upgraded OpsChain Log Aggregator Image to Fluentd 1.13.3.
- Upgraded OpsChain Auth Image to Open Policy Agent 0.31.0.
- Upgraded Terraform to 1.0.3 in the OpsChain examples.
- Upgraded Terraform hashicorp/aws plugin to 3.52.0 in the OpsChain Ansible example.
- Upgraded Terraform kreuzwerker/docker plugin to 2.14.0 in the OpsChain Confluent, Terraform & Weblogic examples.
- Upgraded HashiCorp Vault to 1.8.0 in the OpsChain Vault example.

### Fixed

- A bug with the configure script on macOS has been fixed - `./configure: line 90: ${env_file_contents}${var}=${!var@Q}\n: bad substitution`.

## [2021-07-29]

### Changed

- OpsChain now caches user's LDAP group membership to reduce LDAP load. See [LDAP group membership caching](docs/operations/opschain_ldap.md#LDAP-group-membership-caching) for more details.
- **Breaking change** - Calling OpsChain API's with missing or invalid parameters now returns a 500 Internal Server Error, and more explicit error messages in the response body.
- Upgraded MintPress Gems to 3.14.0.

## [2021-07-19]

### Added

- OpsChain change logs can now be [forwarded to external storage](docs/operations/log_forwarding.md).
- OpsChain change logs can now be [cleaned up automatically](docs/operations/change_log_retention.md).
- When defining dependent steps in the OpsChain DSL the step name is now automatically qualified with the current namespace.
- **Feature preview** - the platform native builds of the OpsChain CLI can now be [downloaded directly](docs/reference/cli.md#opschain-native-cli).

### Changed

- File property paths are now [expanded](https://docs.ruby-lang.org/en/2.7.0/File.html#method-c-expand_path) before being written.
- Running the `configure` script no longer removes unknown configuration options.
- Any resources included in the value supplied to the `properties` resource DSL will have their controller assigned to the relevant property rather than the resource itself. This makes `properties` match the existing functionality for individually set properties.

## [2021-07-08]

### Added

- The [Oracle WebLogic example](https://github.com/LimePoint/opschain-examples-weblogic) now includes a sample WAR file and related `deploy`, `redeploy` and `undeploy` actions.
- A HashiCorp Vault example project repository is [now available](https://github.com/LimePoint/opschain-examples-vault).
- The OpsChain CLI now helps you track the progress of a change by showing the expected step tree.
- The `opchain-action` and `opschain-dev` commands now inherit environment variables starting with `opschain_` (case insensitive).
- The `opschain-action` command now supports the `OPSCHAIN_DRY_RUN` environment variable to see the full expected step tree without running the action.
- OpsChain file properties now supports storing binary files with the new base64 format. See [file formats](docs/reference/concepts/properties.md#file-formats) for more details.

### Changed

- Upgraded Terraform to 1.0.1 in the OpsChain examples.
- Upgraded Terraform plugins in the OpsChain examples - see the commit history of each repository for details.
- Upgraded OpsChain Log Aggregator Image Fluentd to 1.13.1.
- Upgraded OpsChain Auth Image Open Policy Agent 0.30.1.
- Upgraded Bundler to 2.2.21.

## [2021-06-24]

### Added

- `OpsChain.context` is now available to actions and controllers. See the [OpsChain context guide](docs/reference/concepts/context.md) for more information.

### Fixed

- After waiting for the environment change lock, pending changes will be executed in the order they were created. Previously pending changes could start in any order.

### Removed

- **Breaking change** - The `opschain-auth` container is no longer bound to 8081 by default. This binding can be added by following the steps in the [restricting user access guide](docs/operations/restricting_user_access.md#expose-opschain-ldap-and-authorisation-service-server-ports).

## [2021-06-16]

### Added

- Docker build logs for the OpsChain step runner image are included in the change/step logs. They will be shown as part of the output of the `opschain change logs-show` command for new changes.

### Changed

- **Breaking change** - The [assign LDAP group](docs/operations/restricting_user_access.md#assign-ldap-group) ldif example now creates a groupOfNames rather than a posixGroup to support RFC 4519.
  - To use this new group format, you will need to alter the OPSCHAIN_LDAP_GROUP_ATTRIBUTE value in your `.env` file from `memberOf` to `member`
- **Breaking change** - `Automated Deployment Rules` and `Scheduled Deployment Rules` have been renamed to `Automated Change Rules`.
  - The CLI `automated-deployment-{create,delete,list}` and the `scheduled-deployment-{create,delete,list}` subcommands have been combined into a new `opschain automated-change` command.
    - The CLI `--help` argument can be used to see the new names.
- **Breaking change** - The CLI subcommands have been renamed:
  - The convention for CLI subcommands has changed from `noun-verb` to `verb-noun`, for example, `opschain environment properties-set` has been renamed to `opschain environment set-properties`.
- **Breaking change** - The `--commit-ref` and `--ref` options have been renamed to `--git-rev` for consistency. This affects the `opschain change create` and the new `opschain automated-change create` commands.
- **Breaking change** - The `GIT_REF` ARG in custom Dockerfiles has been renamed to `GIT_SHA` - this means that if the Git sha the Git reference points to is altered during a change the steps will still use the original commit (sha).
- `GIT_REV` is now an environment variable that is assigned (with the `git_rev` value of the change) when using the default step runner.
  - A `GIT_REV` ARG is now provided to custom Dockerfiles - this can be assigned to an environment variable (the custom Dockerfile template demonstrates how this can be done).

## [2021-06-10]

### Added

- An Oracle WebLogic example project repository is [now available](https://github.com/LimePoint/opschain-examples-weblogic).
- **Feature preview** - platform native builds of the OpsChain CLI are now available for Windows, macOS and Linux. Contact LimePoint support for access.
- OpsChain now supports Active Directory for user authentication and authorisation. See [configuring an external LDAP](docs/operations/opschain_ldap.md#configuring-an-external-ldap)
  - **This change requires the `configure` command to be rerun.**
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
- **Breaking change** - The OpsChain LDAP database structure has changed. Please remove the files in `OPSCHAIN_DATA_DIR/opschain_ldap` before starting OpsChain.

  _Note: You will need to recreate any users you had created in the OpsChain LDAP._

## [2021-06-01]

### Added

- The ability to use custom Runner images in the OpsChain Docker development environment. Note that the custom Runner image must have been built as part of an OpsChain change.
  - **This change requires the `configure` command to be rerun.**
- The OpsChain CLI now inherits environment variables. This allows using environment variables to override CLI config or to configure http(s) proxies. Find out more in our [CLI reference](docs/reference/cli.md).
- [OpsChain operations guides](docs/operations).
  - [OpsChain rootless Docker install](docs/operations/rootless_install.md) documentation.
  - [OpsChain backups](docs/operations/maintenance/backups.md) documentation.

## [2021-05-26]

### Added

- The OpsChain platform now includes an Authorisation Server allowing you to restrict user access to projects and environments. See [restricting user access](docs/restricting_user_access.md) for more information.
- OpsChain changes can now be cancelled by using the `opschain change cancel` command.

### Changed

- **Breaking change** - The OpsChain CLI now uses kebab-case-arguments (rather than snake_case_arguments) so all multi word arguments have changed.

## [2021-05-17]

### Important breaking changes

- the `opschain_db`, `opschain_ldap` and `opschain_project_git_repos` directories have been moved into a new `opschain_data` directory (`opschain_data` can be overridden as part of the `configure` process)
  - you **must** run `configure` after upgrading to reflect the new directory structure in your `.env` file.
- due to the addition of the project code the OpsChain database needs to be removed and recreated.
  - the path to the project Git repositories has changed from `./opschain_project_git_repos/production/<uuid>` to `./opschain_data/opschain_project_git_repos/<uuid>`.

### Added

- a symbolic link is created as part of the project creation, allowing you to navigate to the project's Git repository via `./opschain_data/opschain_project_git_repos/<project code>`
- **Breaking change** - projects now use (and require) a unique project code.
- The OpsChain Terraform resource type now supports version 0.15.

### Changed

- Environment codes can now be up to 50 characters long.
- **Breaking change** - the OpsChain CLI and API have been altered to use the project code as the project identifier rather than the project id.
- The CLI output for the environment and project list commands has changed - the code field is now shown first and the ID is not shown.

### Removed

- The environment delete API has been removed.
- **Breaking change** - Support for Terraform version 0.14 and lower has been removed from the OpsChain Terraform resource.

## [2021-05-10]

### Added

- OpsChain now supports [automated deployments](docs/reference/concepts/concepts.md#automated-deployment) - a way to automatically create OpsChain changes in response to Git changes. See [setting up an automated deployment](docs/automated_deployment.md) for more information.
- OpsChain now supports [scheduled deployments](docs/reference/concepts/concepts.md#scheduled-deployment) - a way to automatically create OpsChain changes at a scheduled time.

### Changed

- OpsChain now allows properties to be sourced from a project's Git repository. See the updated [OpsChain properties guide](docs/reference/concepts/properties.md) for more information.
- OpsChain now does a Git [forced fetch](https://git-scm.com/docs/git-fetch#Documentation/git-fetch.txt---force) when fetching a project's Git repository. This means tags can be updated in the remote and reflected in the project Git repository.

## [2021-04-27]

### Added

- An example project for [running an AWS Ansible change](docs/examples/running_an_aws_ansible_change.md).
- Helper methods available from within actions to store and remove files from project and environment properties. See [storing & removing files](docs/reference/concepts/properties.md#storing--removing-files) for more details.

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
- **Breaking change** - the OpsChain [files properties](docs/reference/concepts/properties.md#file-properties) format has changed. Any files stored in your properties will need to be altered to reflect the new format.

  _Note: The `properties-show` and `properties-set` features can be used to download, upload your properties (allowing you to edit your properties locally)._

### Fixed

- Hide internal development tasks from the opschain-utils output.
- OpsChain Runner showing "Connection refused - connect(2) for /var/run/docker.sock.opschain" after container restart.

## [2021-03-31]

### Added

- An example project for [running a simple Terraform change](docs/examples/running_a_simple_terraform_change.md).
- The Getting Started guide now includes instructions for creating your own action.

### Changed

- The sample data provided as part of the Getting Started guide has been simplified.
- The `.opschain/step_context.json` file is now optional when running `opschain-action` or `opschain-dev`.
- The `terraform_config` resource type passes any `vars` ([Terraform input variables](https://www.terraform.io/docs/language/values/variables.html)) supplied to Terraform via a [var file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files).

### Removed

- The [Confluent example](https://github.com/LimePoint/opschain-examples-confluent) no longer provides the VarFile class as its functionality has been added to the `terraform_config` resource type.

## [2021-03-22]

### Added

- The `opschain-resource-types` gem is now pre-installed in the OpsChain step runner image providing some [resource types](docs/reference/included_resource_types.md) for the `mintpress-infrastructure` and `ruby-terraform` gems.

  _Please note the [prerequisites](docs/reference/included_resource_types.md#prerequisites) for the Terraform resource._

### Changed

- Replaced `mintpress-infrastructure` resource types in the [Confluent example](https://github.com/LimePoint/opschain-examples-confluent) with those provided by the pre-installed `opschain-resource-types` gem in the OpsChain step runner image.
- [Confluent example](https://github.com/LimePoint/opschain-examples-confluent) Properties
  - Replaced encrypted project properties with unencrypted properties.
  - The host environment for the brokers and control center is now sourced from OpsChain properties.

  _Please note, you will need to [update the project properties](docs/examples/running_a_complex_change.md#import-the-confluent-example-properties) with the new `project_properties.json` before re-running the example._

- The Terraform binary is now installed in the custom step runner Dockerfile as part of the [OpsChain Confluent example](https://github.com/LimePoint/opschain-examples-confluent/blob/75473f7fbac4150b3d5c583dfc52c6b22044552f/.opschain/Dockerfile#L8)

### Removed

- Removed decryption support from example code until MintAESEncryption is fully supported.
- Removed `BUNDLE_CIBUILDER__MINTPRESS_IO` var (from `.env.example`) since it is not used.
- The Terraform binary has been removed from the OpsChain step runner image for parity with other tools which we support but don't bundle.
- Terraform support has been removed from the `opschain-core` gem (Terraform support is now available via the `opschain-resource-types` gem).

## [2021-03-09]

### Added

- Automatically expose [controller actions and properties](docs/reference/concepts/actions.md#controller-actions-and-properties) in resource types and resources.
- [upgrading.md](docs/operations/upgrading.md) documentation.

### Changed

- Upgraded OpsChain log aggregator image Fluentd from version 1.11 to 1.12.1
- Upgraded OpsChain LDAP image OpenLDAP from version 2.4.50 to 2.4.57
- Upgraded OpsChain DB image postgres from 13.1 to 13.2
- Upgraded OpsChain step runner image Terraform from 0.12.29 to 0.14.7.

_Please note:_

1. Project Git repositories will need to be updated:
    - [Terraform 0.12 -> 0.13](https://www.terraform.io/upgrade-guides/0-13.html) - will assist in creating a `versions.tf` in your project Git repository(s).
    - [Terraform 0.13 -> 0.14](https://www.terraform.io/upgrade-guides/0-14.html) - provides information on the new `.terraform.lock.hcl` lock file.
2. You will need to [update the environment properties](docs/examples/running_a_complex_change.md#import-the-confluent-example-properties) with the `environment_properties.json` before re-running the example (to remove the old `tfstate` information).
