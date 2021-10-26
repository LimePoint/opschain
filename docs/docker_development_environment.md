# Docker development environment

The OpsChain Docker development environment enables you to list and run individual actions in a manner similar to a running change. After following this guide you should know how to:

- create a `step_context.json` file to provide environment variables and properties for your action(s)
- list available project resources and actions
- run individual actions
- enter the development container interactively

## Introduction

OpsChain resources and actions can be developed using the `opschain-action` or the `opschain-dev` commands in this repository (these are wrappers for the `opschain-runner-devenv` container).

## Prerequisites

### Navigate to the project Git repository

Commands such as `opschain-action` or `opschain-dev` that use the development container must be run from an OpsChain project Git repository. The files in that directory will then be made available in the container using a [Docker bind mount](https://docs.docker.com/storage/bind-mounts/).

```bash
cd opschain_data/opschain_project_git_repos/<project code>
```

Notes:

- _The path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._
- _The `opschain-action` commands below assume the OpsChain development environment is being run in the original "Demo Hello World" project (created in the Getting Started guide). If using a different project, modify these commands to reflect the OpsChain actions available._

#### Create a `step_context.json` (optional)

The `opschain-action` command uses a `.opschain/step_context.json` file if it exists within the project Git repository working directory. For more information about the `step_context.json` file, see the [actions reference guide](reference/concepts/actions.md#step-context-json).

If your action requires [properties](reference/concepts/properties.md) then you can use the `opschain` `show-properties` sub command to output the required properties values:

```bash
 opschain project show-properties --project-code demo
 opschain environment show-properties --project-code demo --environment-code dev
```

Use the output of these commands to replace the `{}` in the project and environment properties below:

```bash
mkdir -p .opschain
cat << EOF > .opschain/step_context.json
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

If your actions rely on [OpsChain context](reference/concepts/context.md) values, include the required values in a "context" section in the file. E.g.

```text
{
  "context": {
    "project": {
       "code": "demo"
    }
  },
  "project": {
...
```

## Using the OpsChain development environment

The `opschain-action` command can be used to run OpsChain actions the same way they are run by the step runner. See the [running OpsChain actions](getting_started/developer.md#running-opschain-actions) section of the Getting Started guide for instructions on how to list and run individual actions.

Unlike when actions are run as part of an OpsChain change, the OpsChain development environment does not persist changes to the project and environment properties to the OpsChain database. Instead, the properties changes are output into the `.opschain/step_result.json` file. For more information about the `step_result.json` file, see the [actions reference guide](reference/concepts/actions.md#step-result-json).

### Child Steps

#### Viewing step dependencies

The `opschain-action` command can be used to view the expected step tree for an action. Using the `OPSCHAIN_DRY_RUN` environment variable means the step tree will be output without any of the actions running.

_Note: The steps listed may not be accurate during execution because the step information may change dynamically._

```bash
OPSCHAIN_DRY_RUN=true opschain-action hello_world
```

The `step_result.json` will now contain an `expected_step_tree` field showing the complete known step tree for the action.

#### Running child steps

During OpsChain change execution, each child step of an action is executed in its own isolated runner container. As the `opschain-action` command runs locally in a single container, it does not execute an action's child steps. This safeguards the child steps from any issues that may have arisen from running them in the same runner as their parent action. Instead a warning is displayed, detailing the child steps that are not being run.

##### Automatic execution

To enable `opschain-action` to run child steps automatically, configure the `OPSCHAIN_ACTION_RUN_CHILDREN` environment variable (either in your `.env` file, or directly on the command line):

```bash
OPSCHAIN_ACTION_RUN_CHILDREN=true opschain-action hello_world
```

_Notes:_

1. _The `run_as:` `:serial`/`:parallel` flags are taken into account by `opschain-action` and child steps will be executed accordingly._
2. _The `OPSCHAIN_ACTION_RUN_CHILDREN` variable is only applicable to local `opschain-action` usage and has no affect on actions running within an OpsChain change._

##### Manual execution

For more granular control of child step execution, actions and their child steps can be listed on the command line directly, and will be executed in the order specified:

```bash
opschain-action hello_world sample:hello_world_1:run # run the original step and the child step in sequence
```

## Running a step using the interactive development environment

Working directly in the OpsChain development environment container can dramatically simplify the process of developing and testing actions. If your project does not use a custom dockerfile, the `opschain-dev` command can be invoked directly from your project repository. This will interactively enter a Docker container that provides access to the `opschain-action` command for running steps:

```bash
[host] opschain-dev
[container] bundle update opschain-core && bundle install # update to the latest version of opschain-core and install any extra dependencies if needed
[container] opschain-action hello_world # the `opschain-action` command is now available to run steps directly
[container] opschain-action -AT # the `opschain-action` command also supports listing actions
```

Notes:

1. The `opschain-dev` command will mount the current directory (your project repository) as `/opt/opschain` in the OpsChain development environment.
2. Similar to the `opschain-action` command, child steps are not invoked automatically.

## Using `opschain-lint`

OpsChain provides a linting tool for detecting issues in project Git repositories. Currently, it supports only detecting Ruby syntax errors.

The linter can be invoked manually (`opschain-lint`) to test the files in a Git repository - when run like this the linter tests all not-ignored files in the Git repository. The linter can be invoked as `OPSCHAIN_LINT_GIT_KNOWN_ONLY=true opschain-lint` to only lint files tracked by Git.

To reduce the likelihood of committing mistakes into your project repository, the linter can be setup as a pre-commit hook in Git. To create the hook, run the following setup command from the root directory of your project Git repository:

```bash
opschain-lint --setup
```

_Note: The pre-commit hook will automatically ignore untracked files._

If you would like to commit code that fails linting (e.g. incomplete code) the Git `--no-verify` argument can be used when committing, e.g. `git commit --no-verify`.

If you would like to suggest a feature for `opschain-lint` please [contact us](mailto:opschain@limepoint.com).

## Using custom runner images

If your project uses a custom Dockerfile (`.opschain/Dockerfile`) you can use the custom runner image as the base for `opschain-action` or `opschain-dev`.

### Query and use an existing runner image ID

If you have access to the host running the OpsChain worker containers, and have executed a change for your project that successfully built a custom runner, the images built for the change can be found with the following filter:

```bash
docker image ls --filter 'label=opschain.change_id=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
```

_Note: If multiple images were created by the change, we suggest trying the most recently created first._

Start the development environment, using the OPSCHAIN_RUNNER_IMAGE environment variable to specify the runner image to use.

```bash
OPSCHAIN_RUNNER_IMAGE=db25da0dcc7f opschain-dev # or opschain-action
```

_Note: Your image ID will differ from the example above._

### Build and use a custom runner image

If the OpsChain workers are on a remote host or you are yet to run a change with the custom Dockerfile, the image can be built locally. Use the following procedure to create the image:

#### 1. Obtain the standard runner image

The custom Dockerfile must be based on an OpsChain runner image (`limepoint/opschain-runner:latest` or `limepoint/opschain-runner-enterprise:latest`). Ensure you have the image locally or have run the [configure Docker Hub access](getting_started/installation.md#configure-docker-hub-access) steps from the getting started guide.

#### 2. Create a repository tarball

A repository tarball is required to build the custom runner image. From your project repository execute:

```bash
tar -cf repo.tar --exclude=repo.tar .
```

_Note: The project repository is mounted into the container when the image is in use via `opschain-action` or `opschain-dev` so it is not necessary to rebuild this tarball following local repository changes._

#### 3. Create a `step_context_env.json`

The repository build requires a `step_context_env.json` file in the root directory of your project repository. Follow the steps [described earlier](#create-a-step_contextjson-optional) to create the file, being sure to create `./step_context_env.json` rather than `.opschain/step_context.json`.

```bash
cat << EOF > ./step_context_env.json
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

#### 4. Build and use the image

Use the following command to build the custom runner image. _Note: the image tag `custom_runner` can be replaced with a valid Docker tag of your choice_

```bash
docker build --build-arg OPSCHAIN_IMAGE_TAG=latest --build-arg GIT_REV=HEAD --build-arg GIT_SHA=$(git rev-parse HEAD) -t custom_runner -f .opschain/Dockerfile .
```

Start the development environment using the OPSCHAIN_RUNNER_IMAGE environment variable to specify the runner image to use (replace `custom_runner` with the tag used in the build command above if you altered it).

```bash
OPSCHAIN_RUNNER_IMAGE=custom_runner opschain-dev # or opschain-action
```

### Enabling tracing

When running OpsChain actions within the OpsChain development environment container you can enable tracing by setting the OPSCHAIN_TRACE environment variable.

```bash
[container] OPSCHAIN_TRACE=1 opschain-action hello_world
```

## What to do next

Try [developing your own resources](developing_resources.md)

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
