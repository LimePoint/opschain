# Docker development environment

The OpsChain Docker development environment enables you to list and run individual actions in a manner similar to a running change. After following this guide you should know how to:

- create a `step_context.json` file to provide environment variables and properties for your action(s)
- enter the interactive OpsChain development environment to:
  - list available project resources and actions
  - develop and test your project actions

## Introduction

OpsChain resources and actions can be developed using the OpsChain development environment, accessed via the the `opschain dev` CLI command.

## Prerequisites

This guide assumes that you have performed the following steps from the installation guide:

- [Configured Docker Hub access](operations/installation.md#configure-docker-hub-access-optional)
- [Downloaded the OpsChain CLI](reference/cli.md#installation)
- [Created an OpsChain project](getting_started/README.md#create-an-opschain-project)
- [Created a project Git repository](getting_started/developer.md#create-a-git-repository) and associated its remote with your OpsChain project.

### Navigate to the project Git repository

The `opschain dev` command launches an OpsChain step runner Docker container and must be run from an OpsChain project Git repository. The files in that directory will be made available in the container using a [Docker bind mount](https://docs.docker.com/storage/bind-mounts/).

```bash
$ cd /path/to/project/git/repository
$ opschain dev
[dev] $ bundle install
```

_Note: The `opschain-action` commands below assume the OpsChain development environment is being run in the Git repository created as part of the [getting started - developer edition](getting_started/developer.md). If using a different project, modify these commands to reflect the OpsChain actions available._

#### Create a `step_context.json` (optional)

The `opschain-action` command uses a `.opschain/step_context.json` file if it exists within the project Git repository working directory. For more information about the `step_context.json` file, see the [step runner reference guide](reference/concepts/step_runner.md#step-context-json).

```bash
$ mkdir -p .opschain
$ cat << EOF > .opschain/step_context.json
{
   "project": {
      "properties": $(opschain project show-properties -p web)
   },
   "environment": {
      "properties": $(opschain environment show-properties -p web -e test)
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

The `opschain-action` command can be used to run OpsChain actions the same way they are run by the step runner. See the [OpsChain development environment](getting_started/developer.md#opschain-development-environment) section of the getting started guide for instructions on how to list and run individual actions.

Unlike when actions are run as part of an OpsChain change, the OpsChain development environment does not persist changes to the project and environment properties to the OpsChain database. Instead, the properties changes are output into the `.opschain/step_result.json` file. For more information about the `step_result.json` file, see the [step runner reference guide](reference/concepts/step_runner.md#step-result-json).

### Child Steps

#### Viewing step dependencies

Within the OpsChain development environment (accessed via `opschain dev`), the `opschain-action` command can be used to view the expected step tree for an action. Using the `OPSCHAIN_DRY_RUN` environment variable means the step tree will be output without any of the actions running.

_Note: The steps listed may not be accurate during execution because the step information may change dynamically._

```bash
[dev] $ OPSCHAIN_DRY_RUN=true opschain-action deploy_in_maintenance_mode
```

The `step_result.json` will now contain an `expected_step_tree` field showing the complete known step tree for the action.

#### Running child steps

During OpsChain change execution, each child step of an action is executed in its own isolated runner container. As the `opschain-action` command is being run in the OpsChain development environment, it does not execute an action's child steps. This safeguards the child steps from any issues that may arise from running them in the same container as their parent action. Instead a warning is displayed, detailing the child steps that are not being run.

##### Automatic execution

To enable `opschain-action` to run child steps automatically, configure the `OPSCHAIN_ACTION_RUN_CHILDREN` environment variable:

```bash
[dev] $ OPSCHAIN_ACTION_RUN_CHILDREN=true opschain-action deploy_in_maintenance_mode
```

_Notes:_

1. _The `OPSCHAIN_ACTION_RUN_CHILDREN` variable_:
   - _can be set in your shell's configuration, e.g. your `.zshrc`, to persist the config_
   - _is only applicable when using `opschain-action` in the development environment and has no affect on actions running within an OpsChain change_
2. _The `run_as:` `:serial`/`:parallel` flags are ignored by `opschain-action` when running in the development environment. Child steps will always be executed sequentially._

##### Manual execution

For more granular control of child step execution, actions and their child steps can be listed on the command line directly, and will be executed in the order specified:

```bash
[dev] $ opschain-action deploy_in_maintenance_mode enable_maintenance_mode deploy_war disable_maintenance_mode # manually run deploy_in_maintenance_mode and it's children in sequence
```

## Using the OpsChain linter

OpsChain provides a linting tool for detecting issues in project Git repositories. Currently, it only supports detecting Ruby syntax errors. To reduce the likelihood of committing mistakes into your project repository, the linter can be setup as a pre-commit hook in Git. To create the hook, run the following setup command from inside the OpsChain development environment:

```bash
[dev] $ opschain-lint --setup
```

_Note: The pre-commit hook will automatically ignore untracked files._

If you would like to commit code that fails linting (e.g. incomplete code) the Git `--no-verify` argument can be used when committing, e.g. `git commit --no-verify`.

The hook can be removed permanently by removing the pre-commit hook script:

```bash
rm -f .git/hooks/pre-commit
```

If you would like to suggest a feature for OpsChain's linter please [contact us](mailto:opschain-support@limepoint.com).

### Manual linting

The command to invoke the linter manually differs depending on whether you are working inside or outside the OpsChain development environment.

- outside the OpsChain development environment, the linter can be invoked via the OpsChain CLI `opschain dev lint`
- inside the OpsChain development environment, the linter can be invoked via the `opschain-lint` command

When run manually, the linter tests all not-ignored files in the Git repository. To only lint files tracked by Git set the `OPSCHAIN_LINT_GIT_KNOWN_ONLY` environment variable, e.g.

`[host] $ OPSCHAIN_LINT_GIT_KNOWN_ONLY=true opschain dev lint`.

## Custom runner images

### Building the image

If your project uses a custom Dockerfile (`.opschain/Dockerfile`) you can use the OpsChain CLI to create a base Docker image for `opschain dev`. The `opschain dev build-runner-image` command will build the image and tag it as `customer_runner:latest`. If you would prefer a different image tag, include the optional `--tag` argument when running the command:

```bash
[host] $ opschain dev build-runner-image --tag my_custom_runner:1.0.0
```

#### Bundler credentials

If your `.opschain/Dockerfile` uses OpsChain environment variables to supply credentials when running bundler, create a [step context JSON](#create-a-step_contextjson-optional) file in the `.opschain` directory that includes the relevant values and this will be used when building your image.

### Using the image

You can use the custom image as follows:

```bash
[host] $ OPSCHAIN_RUNNER_IMAGE=my_custom_runner:1.0.0 opschain dev
```

_Note: Modify the OPSCHAIN_RUNNER_IMAGE value to reflect the tag of your custom image._

To make the change permanent the OPSCHAIN_RUNNER_IMAGE can be specified in your shell config file, e.g.:

```bash
[host] $ echo export OPSCHAIN_RUNNER_IMAGE=\"my_custom_runner:1.0.0\" >> ~/.zshrc # or ~/.bashrc if using bash
[host] $ exec zsh # reload the shell config by starting a new session (replace zsh with bash as appropriate)
```

Now calls to `opschain dev` will use the custom image by default.

## Enabling tracing

When running OpsChain actions within the OpsChain development environment you can enable tracing by setting the OPSCHAIN_TRACE environment variable.

```bash
[dev] $ OPSCHAIN_TRACE=1 opschain-action hello_world
```

## Removing older runner images

The OpsChain development environment container uses the OpsChain step runner image. Upgrading the CLI will cause a new version of the image to be downloaded. To recover the space used by these older images, the `docker rmi` command can be used to remove them.

_Note: The following commands assume you are not using the OPSCHAIN_RUNNER_IMAGE to specify your runner image._

To list the runner images on your machine, execute the following:

```bash
export OPSCHAIN_BASE_RUNNER="${OPSCHAIN_BASE_RUNNER:-limepoint/opschain-runner}"
docker images --filter "reference=${OPSCHAIN_BASE_RUNNER}:*"
```

Take note of the image ids of the older images and remove them as follows:

```bash
# The image ids below are for example purposes only.
# Replace them with the image ids of the no longer required runner images
# (from the filtered "docker images" command above)
docker rmi 62651bfbd35e b05e297066d6
```

## What to do next

Try [developing your own resources](getting_started/developer.md#developing-resources)

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
