# Step runner reference guide

This guide covers how the OpsChain server executes actions within the OpsChain step runner.

After reading this guide you should understand:

- how to create and use a custom step runner Docker image
- how the API server and step runner exchange critical information

## OpsChain runner images

Each step in an OpsChain change is executed inside a Docker container that is based on an OpsChain runner image.

Each container only runs a single step before it is discarded. This ensures that:

- steps running in parallel do not impact each other
- modifications made by previously completed steps do not affect future steps
- the step execution environment contains only the current project's configuration and files

The image used by the step container is built as part of every step's execution and relies on Docker build caching functionality to keep this performant.

### OpsChain standard runner

The standard OpsChain runner base image is an AlmaLinux-based image that provides a subset of the MintPress controller Gems with an associated Ruby installation and the standard RHEL-packaged base development tooling.

The standard runner image is called `limepoint/opschain-runner` and is configured by default for use in OpsChain.

### OpsChain enterprise runner

The OpsChain enterprise runner is an alternative base runner image that includes the MintPress Oracle controllers, in addition to everything in the standard runner. It is available for use by licenced MintPress customers.

You must be logged in to the [Docker Hub](https://hub.docker.com/) as the `opschainenterprise` user to use the OpsChain enterprise runner - contact [LimePoint](mailto:opschain-support@limepoint.com) to obtain these user credentials.

```bash
docker login --username opschainenterprise
```

Add `OPSCHAIN_RUNNER_NAME='runner-enterprise'` and set `OPSCHAIN_RUNNER_IMAGE='limepoint/opschain-runner-enterprise:latest'` in your `.env` file to use the OpsChain enterprise runner.

After updating the `.env` file, follow the steps from the [upgrading guide](../../operations/upgrading.md) to apply this configuration and fetch the enterprise runner.

### Custom step runner Dockerfiles

If your resources or actions rely on external software, the image used for these containers can be modified to add extra packages or executables. The image may also be modified to optimise the performance of build steps by performing tasks as part of the step image build rather than as part of the step execution.

_Please note: The [Docker development environment](../../docker_development_environment.md#using-custom-runner-images) guide provides instructions on using a custom step runner image with `opschain-action`/`opschain-dev`._

#### Creating a custom step runner Dockerfile

OpsChain provides a template for the step runner image Dockerfile which is the same as the Dockerfile used by OpsChain to build the default step runner image.

Run the following steps from the `opschain-trial` directory to add the Dockerfile template to your repository.

1. Change into your project directory using the project ID:

    ```bash
    cd opschain_data/opschain_project_git_repos/<project code>
    ```

    _Note: The path above assumes the default `opschain_data` path was accepted when you ran `configure` - adapt the path as necessary based on your configuration._

2. Create the `.opschain` directory the Dockerfile will reside in:

    ```bash
    mkdir -p .opschain
    ```

3. Use the `opschain-utils` command to output the template into the Dockerfile:

    ```bash
    opschain-utils dockerfile_template > .opschain/Dockerfile
    ```

4. You can now make your desired modifications to the Dockerfile. See the [supported customisations](#supported-customisations) section for more information.

5. Add and commit the Dockerfile:

    ```bash
    git add .opschain/Dockerfile
    git commit -m "Adding a custom Dockerfile."
    ```

    When running your steps OpsChain will now use this Dockerfile when running changes.

    _Note: Commits before this point won't use the custom Dockerfile because it is not present._

If you no longer wish to use a custom Dockerfile, `.opschain/Dockerfile` can be removed from the project repository.

#### Customising the Dockerfile

This Dockerfile can be modified and committed like any other file in the project Git repository.

The image is built in a Docker build context with access to the following files:

- `repo.tar` - The complete project Git repository including the .git directory with all commit info. This file will change (and invalidate the build context) when a different commit is used for a change or when there are changes to the project's Git repository
- `step_context_env.json` - The environment variables for the project and environment for use by `opschain-exec`. This file will change if the environment variables in the project or environment [properties](properties.md) change

The [Dockerfile reference](https://docs.docker.com/engine/reference/builder/) and the [best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) guide provide more information about writing Dockerfiles.

OpsChain uses [BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/) when building the step image.

#### Supported customisations

Modifying the Dockerfile allows a lot of flexibility.

For maximum compatibility with OpsChain we suggest only using the Dockerfile `RUN`, `COPY`, `ENV`, and `ADD` commands.

More advanced modifications (like modifying the `ENTRYPOINT`) are not supported and may break OpsChain.

Custom Dockerfiles must use the `limepoint/opschain-runner` or `limepoint/opschain-enterprise-runner` image as a base (ie `FROM limepoint/opschain-runner` or `FROM limepoint/opschain-runner-enterprise`).

#### Image performance - base images

OpsChain runs a Docker build for every step within a change.

This is normally performant due to Docker's image build cache - however it is possible to prebuild a custom base image if desired. This may make the image build faster when run for each step.

A custom base image can be created as follows:

1. Create a Dockerfile for the base image that uses `FROM limepoint/opschain-runner` (or `opschain-runner-enterprise` if using the enterprise runner image).

    ```dockerfile
    FROM limepoint/opschain-runner

    # the custom Dockerfile must include the following lines to ensure the OpsChain licence is available to the runner
    ONBUILD ARG OPSCHAIN_LICENCE_BASE64
    ONBUILD ENV OPSCHAIN_LICENCE_BASE64=${OPSCHAIN_LICENCE_BASE64}
    ONBUILD RUN /usr/bin/create_opschain_licence.sh

    # run your custom Docker build commands like any Dockerfile
    # Note: the OpsChain Docker build context files will not be available here
    ```

2. Build and distribute the base image, assigning it a unique tag (the `my-base-image` used below is for example purposes only).

    ```bash
    docker build -t my-base-image .
    ```

3. Use the custom base image in the project custom Dockerfile.

    ```dockerfile
    FROM my-base-image # supply the tag used above

    ... # the rest of the OpsChain custom Dockerfile
    ```

4. Run your change as normal. It will now use the `my-base-image` image as the base for the custom step image.

OpsChain relies on configuration done as part of the base runner image to work. By basing the custom base image on `limepoint/opschain-runner` or `limepoint/opschain-runner-enterprise` the OpsChain configuration still applies and will work as desired.

Ensure that you rebuild your custom image after upgrading OpsChain.

[Contact us](mailto:opschain-support@limepoint.com) if you would like to express your interest in this feature.

## API - step runner integration

When running the step runner, OpsChain includes:

1. the project's Git repository, reset to the requested revision, in the `/opt/opschain` directory
2. the project and environment [properties](properties.md) to be used by the step, in the `/opt/opschain/.opschain/step_context.json` file

Upon completion, the step will produce a `/opt/opschain/.opschain/step_result.json` file to be processed by the API server, detailing:

1. any changes to the project and environment [properties](properties.md) the action has performed
2. the merged set of properties used by the action
3. any child steps to be run after this action (and their execution strategy)

### Step context JSON

#### File structure

The `step_context.json` file has the following structure:

```text
{
  "context": {
    "project": {
      "code": "demo",
      "name": "Demo Project",
      ...
    },
    "environment": ...
    "change": ...
    "step": ...,
    "user": ...
  },
  "project": {
    "properties": {
      "project_property": "value",
      "files": {
        "sample-file": {
          "path": "/path/to/file.txt",
          "mode": "0600",
          "content": "contents of the file"
        }
      },
      "env": {
        "VARIABLE_NAME": "variable value"
      }
    }
  },
  "environment": {
    "properties": {
      "environment_property": "value",
      "files": {
        "different-file": {
          "path": "/path/to/another_file.txt",
          "mode": "0600",
          "content": "contents of the file"
        }
      },
      "env": {
        "VARIABLE_NAME": "variable value"
      }
    }
  }
}
```

#### File content - step context

The `context` values are derived from the current step. The [OpsChain context guide](context.md) provides more details on the values available.

The `project/properties` value is the output from `opschain project show-properties --project-code <project code>`.

The `environment/properties` value is the output from `opschain environment show-properties --project-code <project code> --environment-code <environment code>`

_Replace the `<project code>` and `<environment code>` in the commands above with the values for the project and environment related to the change._

### Step result JSON

The `step_result.json` file has the following structure:

```json
{
  "project": {
    "properties_diff": [
      {
        "op": "add",
        "path": "/new_element",
        "value": "test_value"
      }
    ]
  },
  "environment": {
    "properties_diff": []
  },
  "step": {
    "properties": {
      "opschain": {}
    }
  },
  "steps": {
    "children": [
      {
        "action": "sample:hello_world_1:run"
      }
    ],
    "child_execution_strategy": null
  }
}
```

#### File content - step result

The `project/properties_diff` and `environment/properties_diff` values contain [RFC6902](http://www.rfc-editor.org/rfc/rfc6902.txt) JSON Patch values, describing the changes to apply to the project or environment properties.

The `step/properties` contains the merged set of properties applied to the action. These are linked to the step to support future investigation / debugging.

The `steps/children` value contains the child steps (and execution strategy) the OpsChain workers will execute.

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](/LICENCE.md)
