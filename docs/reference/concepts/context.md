# OpsChain context guide

The OpsChain context framework provides a read only set of values, describing the current step and the user who created the overall change. These values enable you to reuse code between projects and environments, conditionally performing logic based on when and where the step is being performed.

After reading this guide you should understand:

- the information available in the OpsChain context
- how to access the OpsChain context values in your actions

## OpsChain context

Within each action, OpsChain context values are available via `OpsChain.context` (which will behave like a [Hashie Mash](https://github.com/hashie/hashie#mash)[^1])). The `OpsChain.context` includes the following keys:

- `OpsChain.context.project` - project for the currently running step
- `OpsChain.context.environment` - environment for the currently running step
- `OpsChain.context.change` - change the currently running step belongs to
- `OpsChain.context.step` - currently running step
- `OpsChain.context.user` - user who submitted the change

### Nested attributes

#### Change information

The [`project`](concepts.md#project), [`environment`](concepts.md#environment), [`change`](concepts.md#change) and [`step`](concepts.md#step) keys contain the same attributes as those available to you from the relevant API endpoint. To see all the attributes available, create and run the following action in your project:

```ruby
action :print_context do
  puts OpsChain.context.to_yaml
end
```

The logs from this change will include all of the context attributes available to you. E.g.

```yaml
---
project:
  code: demo
  name: Demo Project
  ...
environment: ...
change: ...
step: ...
user:
  name: 'opschain'
  groups: []
```

#### User information

The `user` key includes two attributes:

- `name` - The user who submitted the change
- `groups` - An array of LDAP groups that this user is a member of (if any)

If the current step was associated with a change submitted by the `opschain` user, and `opschain` was a member of the `administrators` and `developers` groups, `OpsChain.context.user` would contain:

```ruby
{
  name: 'opschain',
  groups: ['administrators', 'developers']
}
```

## Accessing the context information

Context information can be accessed using dot or square bracket notation with string or symbol keys. These examples are equivalent:

```ruby
require 'opschain'

OpsChain.context.project.code
OpsChain.context[:project][:code]
OpsChain.context['project']['code']
```

_Note: The `OpsChain.context` structure is read only._

## Example usage

In the example below, running the `main` action in the development environment will set the OpsChain logger to the DEBUG level. When running in any other environment, the OpsChain logger will remain in the default (INFO) level.

```ruby
require 'opschain'

action :enable_logging do
  OpsChain.logger.level = ::Logger::DEBUG if OpsChain.context.environment.code == 'dev'
end

action main: ['enable_logging'] do
  .... main process
end
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
