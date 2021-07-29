# Developing your own resources

Resources and the resource types are the building blocks for OpsChain changes. After following this guide you should understand:

- the relationship between resources, resource types, controllers and actions
- how to use the OpsChain logger to assist with resource development
- how to create your own custom step runner Dockerfiles

_Note: Iterating on resource type, resource and action definitions is made easier by using the [Docker development environment](docker_development_environment.md)._

## Develop a resource controller

The bulk of the logic for your resource should be enclosed within a [controller](reference/concepts.md#controller) class. This simplifies unit testing and reduces complexity in `resource_types.rb`.

Notes:

- The class constructor must accept a single [Ruby hash](https://ruby-doc.org/core-2.7.0/Hash.html) parameter, which will include each of the resource properties defined on the resource.
- The action methods must not require parameters.

Example controllers can be seen in the [actions reference guide](reference/actions.md#controller) and within the [Confluent OpsChain example project](https://github.com/LimePoint/opschain-examples-confluent).

## Define a resource type

Once the controller class has been written and tested, define your [resource type](reference/concepts.md#resource-type), referencing your custom controller class. Use the `action_methods` keyword to create actions for those controller methods that do not require pre or post requisite actions (see [defining standalone actions](reference/actions.md#defining-standalone-actions) for more details)

_Note: Resource types are commonly stored in `resource_types.rb` but can be included in any file that is required by your `actions.rb`._

### Define resource properties

Ensure you define a resource property for each hash key your controller class is expecting in its constructor. (See the [controller](reference/concepts.md#controller) example in the Reference Guide)

### Define additional resource actions

If your action(s) have pre or post requisite actions, define the actions within the resource type itself (see the [actions reference guide](reference/actions.md) for information on creating actions).

For example the following code creates a `database` resource type with four actions: `copy_installer`, `install_and_startup`, `startup` and `shutdown`.

```ruby
require 'database_controller'

resource_type :database do
  controller DatabaseController, action_methods: [:copy_installer, :startup, :shutdown]
  property :host
  property :source_path

  action install_and_startup: [:copy_installer], steps: [:startup] |type|
    type.controller.install
  end
end
```

The `install_and_startup` action will:

1. execute the `copy_installer` pre-requisite action (to execute the `copy_installer` controller method)
2. execute the `install` controller method (manually called from within the action body)
3. request the `startup` action be run as a child step (to execute the `startup` controller method)

## Define a resource

Once the resource type has been defined, use this in your `actions.rb` file to create a [resource](reference/concepts.md#resource). For example the following `actions.rb` file will create a `my_database` resource, with the four actions defined in the type:

```ruby
require 'resource_types'

database :my_database do
  host 'localhost'
  source_path '/var/tmp/db_installer.sh'
end
```

_Note: Based on the type and resource definitions above, the DatabaseController instance for `my_database` will be constructed as follows:_

```ruby
DatabaseController.new(
  host: 'localhost',
  source_path: '/var/tmp/db_installer.sh'
)
```

## OpsChain logger

The OpsChain logger is a standard Ruby Logger object. By default the logger is configured to log all INFO severity (and higher) messages to STDOUT. You can use the OpsChain logger from anywhere in your `actions.rb` or project code:

```ruby
require 'opschain'

OpsChain.logger.info "Informational message"
OpsChain.logger.warn "Warning message"
OpsChain.logger.error "Error message"
OpsChain.logger.fatal "Fatal message"
```

If required, the logger can be set to also display DEBUG level messages as follows:

```ruby
OpsChain.logger.level = ::Logger::DEBUG
OpsChain.logger.debug "Debug message"
```

## Custom step runner Dockerfiles

If your resource requires external packages, you will need to include a [custom step runner Dockerfile](reference/actions.md#custom-step-runner-dockerfiles) in your project Git repository. This will allow you to include the required software on the OpsChain step runner container running your change.

### Creating a custom step runner Dockerfile

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

4. You can now make any modifications to the Dockerfile you desire (See the [supported customisations](reference/actions.md#supported-customisations) section of the Reference Guide for more information).

5. Add and commit the Dockerfile:

    ```bash
    git add .opschain/Dockerfile
    git commit -m "Adding a custom Dockerfile."
    ```

    When running your steps OpsChain will now use this Dockerfile when running changes.

    _Note: Commits before this point won't use the custom Dockerfile because it is not present._

## Licence & authors

- Author:: LimePoint (support@limepoint.com)

See [LICENCE](../LICENCE)
