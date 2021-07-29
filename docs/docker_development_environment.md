# Docker Development Environment

The OpsChain Docker development environment enables you to list and run individual actions in a manner similar to a running change.  After following this guide you should know how to:
- create a `step_context.json` file to provide environment variables and properties for your action(s)
- list available project resources and actions
- run individual actions
- enter the development container interactively
- interpret the contents of the `step_result.json`

## Introduction

OpsChain resources and actions can be developed using the `opschain-action` or the `opschain-dev` script in this repository (these are wrappers for the `opschain-runner-devenv` container).

## Pre-requisites

### Navigate to the Project Git Repository

Commands such as `opschain-action` or `opschain-dev` that use the development container must be run from an OpsChain project Git repository. The files in that directory will then be made available in the container using a [Docker bind mount](https://docs.docker.com/storage/bind-mounts/).

```bash
$ cd opschain_project_git_repos/production/$project_id
```

_Note: The `opschain-action` commands below assume the OpsChain development environment is being run in the original "Payables Team" project (created in the Getting Started guide), including setting the `project_id` environment variable.  If using a different project, modify these commands to reflect the OpsChain actions available._

#### Create a `step_context.json`

The `opschain-action` script requires that a `.opschain/step_context.json` file exists within the project Git repository.  For more information about the `step_context.json` file, see the [Actions Reference Guide](reference/actions.md#step-context-json).

Currently, you will need to create this file manually.  If your action does not require OpsChain [properties](reference/properties.md) values, create the `.opschain/step_context.json` file as follows:

```bash
$ mkdir -p .opschain
$ cat << EOF > .opschain/step_context.json
{
   "project": {
      "properties": {}
   },
   "environment": {
      "properties": {}
   }
}
EOF
```

If your action does require [properties](reference/properties.md) use the `opschain` `properties-show` sub command to output the required properties values:

```bash
$ opschain project properties-show --project_id $project_id
$ opschain environment properties-show --project_id $project_id --environment_code $environment_code
```

Use the output of these commands to replace the empty `{}` properties in the empty file above.

### Using the OpsChain Development Environment

The `opschain-action` script can be used to run OpsChain actions the same way they are run by the step runner.

#### Listing Actions Using `opschain-action`

The `opschain-action` script can be invoked to list the actions defined in the current project Git repository:

```bash
$ opschain-action -AT
```

#### Running a Step Using `opschain-action`

The `opschain-action` script can be invoked to run actions defined in the current project Git repository (multiple actions can be specified in order):

```bash
$ opschain-action hello_world
```

_Note that child steps are not invoked by the OpsChain development environment. See the [Viewing the `step_result.json`](#viewing-the-step_resultjson) section for more details._

### Entering the OpsChain Development Environment Container Interactively

The `opschain-dev` script can be invoked to interactively enter a Docker container that provides access to the `opschain-action` command for running steps:

```bash
[host] $ opschain-dev
[container] $ bundle update opschain-core && bundle install # update to the latest version of opschain-core and install any extra dependencies if needed
[container] $ opschain-action hello_world # the `opschain-action` command is now available to run steps directly
[container] $ opschain-action -AT # the `opschain-action` command also supports listing actions
```

_Note that child steps are not invoked by the OpsChain development environment. See the [Viewing the `step_result.json`](#viewing-the-step_resultjson) section for more details._

### Viewing the `step_result.json`

Running an action via the `opschain-action` command will write a `.opschain/step_result.json` file into your project Git repository. For more information about the `step_result.json` file, see the [Actions Reference Guide](reference/actions.md#step-result-json).

As above, the OpsChain development environment does not run dependent steps and instead outputs them into the step result file. This is because they would be added to the OpsChain workers' job queue to be run in a separate runner container.

Updates to project and environment properties are also output into this file. They are not persisted to the `step_context.json`.

Subsequent steps in the step context file could be run manually either individually or in a sequence, for example:

```bash
$ opschain-action sample:hello_world_1:run # just run the child step
$ opschain-action hello_world sample:hello_world_1:run # run the original step and the child step in sequence
```

## What to Do Next

Try [Developing Your Own Resources](developing_resources.md)

# Licence & Authors
- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
