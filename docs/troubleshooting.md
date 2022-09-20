# Troubleshooting

After following this guide you should understand:

- how to resolve known OpsChain issues
- workarounds for known OpsChain limitations

## General advice

When errors are encountered with OpsChain, the following high-level checklist may be useful:

- check the log output from any relevant changes using `opschain change show-logs`
- check the log output from Kubernetes, e.g. via [`kubetail -n opschain --since 0`](https://github.com/johanhaleby/kubetail)
  - to see the logs for a specific OpsChain service using `kubetail`, run `kubetail {{service}} -n opschain` (use `kubectl get deployments -n opschain` to see the list of OpsChain services)
- ensure the OpsChain [hardware/VM prerequisites](operations/installation.md#hardwarevm-requirements) are met
  - ensure that adequate disk space is still available
- ensure the system time is accurate
- check [known issues](#known-issues) below
- restart OpsChain and try again
- [contact us](support.md#how-to-contact-us) for support

## Known issues

### OpsChain change - `BUG: error: failed to solve`

OpsChain changes may fail with the following error: `BUG: error: failed to solve: opschain-image-registry:8000/limepoint/opschain-runner:2022-05-25 opschain-image-registry:8000/limepoint/opschain-runner:2022-05-25: not found`.

#### Solution - `BUG: error: failed to solve`

Run the following command in your OpsChain server configuration directory (e.g. `~/opschain-configuration`) and then retry your change:

```bash
source .env
kubectl exec -ti -n ${OPSCHAIN_KUBERNETES_NAMESPACE} deploy/opschain-api-worker -- /usr/bin/container_start.sh 'rake opschain:copy_runner_image'
```

### Container "xxxxxxxxxxxx" is unhealthy

The most likely cause of this issue is an invalid or expired licence file, although other scenarios can cause a container to be flagged as unhealthy. To view the container log files execute:

```bash
kubetail -n opschain --since 0
```

_Note: if you would like to view the logs of a single service, include the service name in the command e.g. `kubetail opschain-api -n opschain --since 0`. A complete list of the OpsChain services is available via `kubectl get deployments -n opschain`._

#### Expired / invalid licence

If your licence file is invalid or has expired when you attempt to start the OpsChain containers, the `opschain-api` will be _unhealthy_ and the service logs will include a message reflecting the licence state:

```text
OpsChain licence file (opschain.lic) has expired.

To obtain a valid licence, please contact LimePoint via:
  - Slack: https://limepoint.slack.com/messages/opschain-support
  - E-mail: opschain-support@limepoint.com
```

#### Other errors

If the logs reflect a different error, please use the [`#opschain-support` Slack channel](https://limepoint.slack.com/messages/opschain-support) or [email](mailto:opschain-support@limepoint.com) for further assistance.

### OpsChain CLI changes not showing step status (showing � instead)

The OpsChain CLI uses emoji characters to show the step status.

Older terminals, such as the Windows Command Prompt, do not support emojis. Similarly, not all terminal fonts include the required emojis.

#### Solution - step status rendering

We suggest using a terminal (and font) that supports emojis - for example using the newer [Windows Terminal](https://aka.ms/terminal) if on Windows.

Alternatively, if this is not possible, the CLI can be configured to output these statuses as text.

Set the `stepEmoji` CLI configuration option to `false` to show text rather than emojis for the step status - see the [CLI configuration guide](reference/cli.md#opschain-cli-configuration) for more details.

### `opschain-exec` / `opschain-action` - Argument list too long

When using the `opschain-exec` or `opschain-action` commands (for example during an OpsChain step runner image build or from within the OpsChain development environment) the command may fail with the following error:

```bash
.../bin/opschain-exec:4:in `exec': Argument list too long - ... (Errno::E2BIG)
```

This error indicates that the [Environment Variable](reference/concepts/properties.md#environment-variables) properties stored in the OpsChain properties linked to your project and/or environment are too large.

Linux systems have a limit on the size of arguments and environment variables when executing commands. This is the `ARG_MAX` property. `opschain-exec` and `opschain-action` are limited by this system limit.

The `Limits on size of arguments and environment` section in `man 2 execve` talks more about this limit, or more details can be found via your favourite search engine.

#### Solution - E2BIG

You will need to reduce the size of the environment variables in your project or environment [properties](reference/concepts/properties.md)

To resolve this issue remove environment variables (or reduce the size of environment variable names/values) until the error stops appearing - we recommend limiting the size of the environment variables structure to smaller than 64KB to be safe. This is the combined total of project and environment environment variables.

### `opschain-action` / `opschain-dev` - Could not find proper version of opschain-core (XXXXX) in any of the sources

When using the `ospchain-action` or `opschain-dev` command you may encounter the following error (your version will vary):

```bash
[dev] $ opschain-action -AT # or another command
Could not find proper version of opschain-core (0.1.0.82) in any of the sources
Run `bundle install` to install missing gems.
```

This can happen when you've pulled the latest OpsChain images.

The `Gemfile.lock` in the OpsChain project Git repository specifies a particular version of the `opschain-core` Gem. This version changes when pulling the newer OpsChain images.

#### Solution - proper version of OpsChain-Core

The simplest solution is to remove the `Gemfile.lock`, e.g.:

```bash
rm -f Gemfile.lock
```

Alternatively, the `Gemfile.lock` can be updated by running:

```bash
$ opschain dev
[dev] $ bundle update opschain-core
```

You can then continue with your original command.

### Poor image build performance

The OpsChain image build service relies on the snapshotting features of the overlayfs or fuse-overlayfs file systems to provide fast layer caching. If the overlayfs and fuse-overlayfs filesystems are unavailable, the build service will fall back to a native snapshotter, causing image build times to be considerably slower. Use the following command to search the build service logs to see if the native snapshotter is in use:

```bash
kubectl logs service/opschain-build-service -n opschain | grep 'native'
```

If the results include output similar to the example below, the build service is using the non-performant snapshotter. E.g.

```text
fuse-overlayfs is not available for /home/user/.local/share/buildkit, falling back to native: fuse-overlayfs not functional, make sure running with kernel >= 4.18: failed to mount
auto snapshotter: using native
```

#### Solution - enable privileged build-service

To configure the build-service to run in a privileged container (that will be able to use overlayfs), edit your `.env`, setting:

```dotenv
OPSCHAIN_IMAGE_BUILD_ROOTLESS=false
```

## Known errors/limitations

### Special characters in resource names

When an OpsChain resource name contains special characters it can't be referenced normally.

The following error may be shown in these cases (however it is not the only type of error that may be reported):

```ruby
NameError: undefined local variable or method `...' for #<OpsChain::Dsl::ResourceConfiguration:...>
```

This error can occur in code like the following:

```ruby
infrastructure_host 'test.opschain.io'

some_resource 'something' do
  host test.opschain.io # attempt to reference the infrastructure_host above
end
```

This code will fail because the `test.opschain.io` resource can't be looked up directly due to the special characters in the resource name.

#### Solution - `ref`

A `ref` method is provided to handle the case where a resource name contains special characters

```ruby
infrastructure_host 'test.opschain.io'

some_resource 'something' do
  host ref('test.opschain.io')
end
```

The `ref` (short for reference) method looks up the resource in the same way as [referencing previous resources](reference/concepts/actions.md#referencing-resources).

### Git commit: `opschain: command not found`

OpsChain automatically sets up the [`opschain dev lint` tool](docker_development_environment.md#using-the-opschain-linter) to detect issues in the project Git repositories.

If the command is not available on the path when committing the following error will be shown:

```text
.git/hooks/pre-commit: line 2: exec: opschain: not found
```

#### Solution - `opschain: not found`

To enable the `opschain dev lint` command as part of the Git pre-commit hook, it needs to be added to the PATH. Alternatively, the pre-commit hook could be modified to include the full path to the `opschain` binary.

Alternatively, the pre-commit hook can be removed from the project Git repository:

```bash
cd {{project git repository}}
rm -f .git/hooks/pre-commit
```

Or, if you would like to skip the hook just once, the `--no-verify` argument can be used when committing.

### Updates made to properties in change "...", step "..." could not be applied

The following error highlights that actions running in concurrent steps have made incompatible modifications to project and/or environment properties and OpsChain is unable to successfully apply the JSON Patch with these property updates.

```ruby
Failed processing step: /opt/opschain/app/commands/process_step_result_command.rb:17:in `rescue in call': Failed processing step "bar" (ProcessStepResultCommand::Error)
# ...
rescue in apply_properties_diff!': Updates made to properties in change "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", step "[xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx] bar" could not be applied - see change logs for more details. (ProcessStepResultCommand::Error)
# ...
in `remove_operation': JSON::PatchObjectOperationOnArrayException (JSON::PatchObjectOperationOnArrayException)
# ...
```

#### Solution - updates made to properties could not be applied

The change logs of the change specified in the error will include a number of JSON documents containing the necessary information to manually correct the OpsChain properties. See the [resolving conflicts](reference/concepts/properties.md#resolving-conflicts) section of the properties reference guide for more information.

##### Preventing future properties update failures

The [properties reference guide](reference/concepts/properties.md#changing-properties-in-concurrent-steps) includes a number of examples of properties updates that will cause JSON Patch failure. Review the code in your `actions.rb` and where possible avoid these types of updates.

### OpsChain change - `OpsChain wait steps can't be created as actions - they can only be used as steps.`

OpsChain [wait steps](reference/concepts/actions.md#wait-steps), and the associated `OpsChain.wait_step` method, can't be used as an action name. This means that the following code is invalid:

```ruby
# invalid, don't do this
action OpsChain.wait_step, steps: [:do_something]
```

#### Solution - use `OpsChain.wait_step` as the first child of the change action

```ruby
action :do_something_with_acknowledgement, steps: [OpsChain.wait_step, :do_something]
```

### OpsChain change - `OpsChain wait steps can't be used as prerequisites.`

OpsChain [wait steps](reference/concepts/actions.md#wait-steps), and the associated `OpsChain.wait_step` method, can't be used as [prerequisite actions](reference/concepts/actions.md#prerequisite-actions). This means that the following code is invalid:

```ruby
# invalid, don't do this
action do_something: [OpsChain.wait_step] do
  # after wait step
end
```

#### Solution - only use `OpsChain.wait_step` within `steps`

OpsChain wait steps can only be used within the `steps` definition. Restructuring the example above allows the code to use the `OpsChain.wait_step` in the `steps` definition rather than as a prerequisite:

```ruby
action :do_something_with_acknowledgement, steps: [OpsChain.wait_step, :do_something]

action :do_something do
  # after wait step
end
```

### OpsChain change - parallel steps run before wait step

OpsChain [wait steps](reference/concepts/actions.md#wait-steps), and the associated `OpsChain.wait_step` method, can be used with parallel `steps` - however this means that all the sibling parallel steps will kickoff whilst the wait step is waiting, not before. For example:

```ruby
# warning - the `do_something_1` and `do_something_2` steps will run before the wait step has been continued
action :broken_acknowledgement_example, steps: [OpsChain.wait_step, :do_something_1, :do_something_2], run_as: :parallel
```

#### Solution - parallel steps with wait step

To make the change pause before the parallel steps, add a step that runs before the parallel steps:

```ruby
action :do_something_with_acknowledgement, steps: [OpsChain.wait_step, :do_something_parallel]

action :do_something_parallel, steps: [:do_something_1, :do_something_2], run_as: :parallel
```

### OpsChain dev - `Starting OpsChain development environment failed: Error: spawnSync docker ENOENT`

The `opschain dev` subcommands rely on the `docker` executable to function.

#### Solution - install the dev dependencies

Install the CLI [dev dependencies](reference/cli.md#dev-subcommand-dependencies) and then run the command again.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
