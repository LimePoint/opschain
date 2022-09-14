# Changes reference guide

This guide covers OpsChain changes, creating them, managing their execution and limitations to be aware of. After reading this guide you should understand:

- how to create a change
- configuration options available to control change execution
- adding and using change metadata

## Overview

A change is the application of an action from a specific commit in the project's Git repository, to a particular project environment. The action(s) defined in the repository's `actions.rb` file allow you to structure your changes in a variety of ways and will be influenced by the tools you use with OpsChain. You may structure your changes using "desired state" techniques, or by applying explicit actions (e.g. upgrading a single package in response to a security vulnerability).

### Creating a change

OpsChain changes can be created via the OpsChain CLI, or by directly POSTing to the API changes endpoint. To create an OpsChain change, the following information is required:

- An OpsChain [project](concepts.md#project) and [environment](concepts.md#environment)
- A [Git remote](git_remotes.md) and related Git reference (tag/branch/SHA)
- The OpsChain [action](actions.md) to execute

_Note: For more information on using the CLI to create a change, see `opschain change create --help`. See OpsChain's API reference for more information on creating changes directly via the API (to see the API reference documentation, use a browser to access the API host)._

## Change properties

To unlock the true power of OpsChain, your actions should be constructed to take advantage of the OpsChain [properties](properties.md) framework. This allows the actions to dynamically source hostnames, credentials and other project/environment specific information at runtime rather than being hard-coded into the actions.

### Static properties

The change's Git reference identifies the static [repository properties](properties.md#git-repository) that will be supplied to the change. As detailed in the [OpsChain properties guide](properties.md#opschain-properties), repository properties can be overridden by project and environment properties.

### Dynamic properties

As each step in your change is constructed, OpsChain will supply it with the latest version of the change's project and environment [database properties](properties.md#database). This ensures any modifications made to the properties in prior change steps (or other changes) are available to the action.

## Change execution

A step will be created for the change action, with additional steps created for each child action. The [child execution strategy](actions.md#child-execution-strategy) specified by each action will determine whether its child actions are executed serially or in parallel.

_Note: The number of OpsChain worker nodes configured when the OpsChain server is deployed provides a hard limit on the number of steps that OpsChain can execute at a time. For example, with 3 worker nodes, OpsChain can run:_

- _3 parallel steps from a single change_
- _3 individual steps from 3 distinct changes_
- _2 parallel steps from one change, and one step from another_

### Limitations

The OpsChain properties guide highlights a number of limitations that must be taken into account when [changing properties in concurrent steps](properties.md#changing-properties-in-concurrent-steps).

### Change execution options

By default, OpsChain will only allow a single change to execute for each project environment. This aims to reduce the likelihood that the limitations described above will impact running changes. However, if the actions in your project's Git repository perform logic that can be run concurrently within a single environment, and they interact with the database properties in a manner that will not be impacted by the limitations, you can configure the project to allow concurrent changes within the project's environments. To do this, set the `allow_concurrent_changes` option to `true` in your project's properties as follows:

```json
{
  "opschain": {
    "config": {
      "environments": {
        "allow_concurrent_changes": true
      }
    }
  },
  ...
}
```

_Note: if you have `jq` installed you can use the following command to set the option programmatically:_

```bash
opschain project show-properties -p <your project code> | jq '.opschain.config.environments += { "allow_parallel_changes": true }' > /tmp/updated_project_properties.json
opschain project set-properties -p <your project code> -f /tmp/updated_project_properties.json -y
```

## Change metadata

When creating a change, OpsChain allows you to associate additional metadata with a change. This metadata can then be used:

- when reporting on and searching the change history (via the API)
- from within your `actions.rb` actions

### Adding metadata to a change

Create a JSON metadata file to associate with the change:

```bash
cat << EOF > change_metadata.json
{
  "change_request": "CR921",
  "approver": "A. Manager"
}
EOF
```

Use the CLI to associate the metadata with a change:

```bash
opschain change create -p project -e environment -m prod_change_metadata.json -a action -g git_rev -G git_remote -y
```

### Query changes by metadata

The output from the API can now be filtered using [`jq`](https://github.com/stedolan/jq) to only display those changes whose approver matches the value we specified in the metadata:

```bash
curl http://opschain:password@localhost:3000/changes | jq -r '.data[] | select(.attributes.metadata.approver == "A. Manager")'
```

_Note: Update the username, password, host and port to reflect your OpsChain server configuration._

### Using metadata in actions

The change metadata can also be accessed from within your `actions.rb` via [OpsChain context](context.md). The following action would output the approver into the change log:

```ruby
action :print_approver do
  OpsChain.logger.info "The change approver is: #{OpsChain.context.change.metadata.approver}"
end
```

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
