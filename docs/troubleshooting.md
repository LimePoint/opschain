# Troubleshooting

After following this guide you should understand:

- how to resolve known OpsChain issues
- workarounds for known OpsChain limitations

## Known issues

### OpsChain CLI changes not showing step status (showing � instead)

The OpsChain CLI uses emoji characters to show the step status.

Older terminals, such as the Windows Command Prompt, do not support emojis. Similarly, not all terminal fonts include the required emojis.

#### Solution - step status rendering

We suggest using a terminal (and font) that supports emojis - for example using the newer [Windows Terminal](https://aka.ms/terminal) if on Windows.

Alternatively, if this is not possible, the CLI can be configured to output these statuses as text.

Set the `stepEmoji` CLI configuration option to `false` to show text rather than emojis for the step status - see the [CLI configuration guide](reference/cli.md#opschain-cli-configuration) for more details.

### `opschain-exec` / `opschain-action` - Argument list too long

When using the `opschain-exec` or `opschain-action` commands (for example during an OpsChain step runner image build or local development activities) the command may fail with the following error:

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
$ opschain-action -AT # or another command
Could not find proper version of opschain-core (0.1.0.82) in any of the sources
Run `bundle install` to install missing gems.
```

This can happen when you've pulled the latest OpsChain Docker images.

The `Gemfile.lock` in the OpsChain project Git repository specifies a particular version of the `opschain-core` Gem. This version changes when pulling the newer OpsChain images.

#### Solution - proper version of OpsChain-Core

The simplest solution is to remove the `Gemfile.lock`, eg:

```bash
rm -f Gemfile.lock
```

Alternatively, the `Gemfile.lock` can be updated by running:

```bash
[host] opschain-dev
[container] bundle update opschain-core
[container] exit
```

You can then continue with your original command.

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

The `ref` (short for reference) method looks up the resource in the same way as [referencing previous resources](reference/concepts/actions.md#referencing-previous-resources).

## Workarounds (YMMV)

_Workarounds or tips mentioned in this section are unsupported and may stop working in the future._

### Git remotes with SSH authentication

A workaround to allow adding a Git remote that requires SSH authentication is to bind mount an authorized SSH private key into the OpsChain API container and the OpsChain Worker container.

In the `opschain-trial` directory create a `docker-compose.override.yml` that bind mounts an SSH private key and a known_hosts file into the containers, for example:

```yaml
version: '2.4'

services:
  opschain-api:
    volumes:
      - /path/to/id_ed25519:/opt/opschain/.ssh/id_ed25519
      - /path/to/.ssh/known_hosts:/opt/opschain/.ssh/known_hosts
  opschain-api-worker:
    volumes:
      - /path/to/id_ed25519:/opt/opschain/.ssh/id_ed25519
      - /path/to/.ssh/known_hosts:/opt/opschain/.ssh/known_hosts
```

_If using an OPSCHAIN_UID of `0` the `/opt/opschain/.ssh` paths needs to be replaced with `/root/.ssh`._

After doing this the OpsChain Docker containers need to be restarted.

(If required, the `known_hosts` file can be created by running `ssh-keyscan {git_remote_host} > known_hosts` - for example `ssh-keyscan github.com > known_hosts`.)

The SSH key and known_hosts are used by the `opschain` user in the containers - which is a user account with the UID from `OPSCHAIN_UID` in `.env`, and the equivalent GID based on `OPSCHAIN_GID`. Hence, the file permissions of the SSH key and known_hosts file must be correct for this user account.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
